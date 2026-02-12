# 🔄 State Management Skill

> Bloc, Cubit ve Riverpod pattern'leri — doğru state çözümünü seçme rehberi

---

## Ne Zaman Ne Kullan?

```
State karmaşıklığı?
├── Basit (toggle, counter, form) → Cubit
├── Orta (API call, CRUD) → Bloc
├── Complex (real-time, multi-source) → Bloc + Stream
└── Global (theme, auth, locale) → Cubit (app seviyesinde)
```

---

## Bloc Pattern (Standart)

### Event Tanımı (Freezed ile)
```dart
// lib/features/task/presentation/bloc/task_list_event.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_list_event.freezed.dart';

@freezed
class TaskListEvent with _$TaskListEvent {
  const factory TaskListEvent.loadRequested() = TaskListLoadRequested;
  const factory TaskListEvent.refreshRequested() = TaskListRefreshRequested;
  const factory TaskListEvent.nextPageRequested() = TaskListNextPageRequested;
  const factory TaskListEvent.taskToggled(String taskId) = TaskListTaskToggled;
  const factory TaskListEvent.taskDeleted(String taskId) = TaskListTaskDeleted;
  const factory TaskListEvent.filterChanged(TaskFilter filter) = TaskListFilterChanged;
}
```

### State Tanımı (Freezed ile)
```dart
// lib/features/task/presentation/bloc/task_list_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_list_state.freezed.dart';

enum TaskListStatus { initial, loading, success, failure }

@freezed
class TaskListState with _$TaskListState {
  const factory TaskListState({
    @Default(TaskListStatus.initial) TaskListStatus status,
    @Default([]) List<Task> tasks,
    @Default(TaskFilter.all) TaskFilter filter,
    @Default(1) int currentPage,
    @Default(false) bool hasReachedMax,
    String? errorMessage,
  }) = _TaskListState;
}
```

### Bloc İmplementasyonu
```dart
// lib/features/task/presentation/bloc/task_list_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final GetTasks _getTasks;
  final ToggleTask _toggleTask;
  final DeleteTask _deleteTask;

  TaskListBloc({
    required GetTasks getTasks,
    required ToggleTask toggleTask,
    required DeleteTask deleteTask,
  })  : _getTasks = getTasks,
        _toggleTask = toggleTask,
        _deleteTask = deleteTask,
        super(const TaskListState()) {
    on<TaskListLoadRequested>(_onLoadRequested);
    on<TaskListRefreshRequested>(_onRefreshRequested);
    on<TaskListNextPageRequested>(
      _onNextPageRequested,
      transformer: droppable(),  // Concurrent request'leri engelle
    );
    on<TaskListTaskToggled>(_onTaskToggled);
    on<TaskListTaskDeleted>(_onTaskDeleted);
    on<TaskListFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadRequested(
    TaskListLoadRequested event,
    Emitter<TaskListState> emit,
  ) async {
    emit(state.copyWith(status: TaskListStatus.loading));

    final result = await _getTasks(
      GetTasksParams(page: 1, filter: state.filter),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: TaskListStatus.failure,
        errorMessage: failure.message,
      )),
      (tasks) => emit(state.copyWith(
        status: TaskListStatus.success,
        tasks: tasks,
        currentPage: 1,
        hasReachedMax: tasks.length < 20,
      )),
    );
  }

  Future<void> _onRefreshRequested(
    TaskListRefreshRequested event,
    Emitter<TaskListState> emit,
  ) async {
    final result = await _getTasks(
      GetTasksParams(page: 1, filter: state.filter),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (tasks) => emit(state.copyWith(
        tasks: tasks,
        currentPage: 1,
        hasReachedMax: tasks.length < 20,
      )),
    );
  }

  Future<void> _onNextPageRequested(
    TaskListNextPageRequested event,
    Emitter<TaskListState> emit,
  ) async {
    if (state.hasReachedMax) return;

    final nextPage = state.currentPage + 1;
    final result = await _getTasks(
      GetTasksParams(page: nextPage, filter: state.filter),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (tasks) => emit(state.copyWith(
        tasks: [...state.tasks, ...tasks],
        currentPage: nextPage,
        hasReachedMax: tasks.length < 20,
      )),
    );
  }

  Future<void> _onTaskToggled(
    TaskListTaskToggled event,
    Emitter<TaskListState> emit,
  ) async {
    // Optimistic update
    final updatedTasks = state.tasks.map((task) {
      if (task.id == event.taskId) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();

    emit(state.copyWith(tasks: updatedTasks));

    // Server'a gönder
    final result = await _toggleTask(ToggleTaskParams(taskId: event.taskId));
    result.fold(
      (failure) {
        // Rollback
        emit(state.copyWith(
          tasks: state.tasks,
          errorMessage: failure.message,
        ));
      },
      (_) {},  // Başarılı — optimistic update zaten uygulandı
    );
  }

  Future<void> _onTaskDeleted(
    TaskListTaskDeleted event,
    Emitter<TaskListState> emit,
  ) async {
    final originalTasks = state.tasks;
    final updatedTasks = state.tasks
        .where((task) => task.id != event.taskId)
        .toList();

    emit(state.copyWith(tasks: updatedTasks));

    final result = await _deleteTask(DeleteTaskParams(taskId: event.taskId));
    result.fold(
      (failure) => emit(state.copyWith(
        tasks: originalTasks,
        errorMessage: failure.message,
      )),
      (_) {},
    );
  }

  Future<void> _onFilterChanged(
    TaskListFilterChanged event,
    Emitter<TaskListState> emit,
  ) async {
    emit(state.copyWith(filter: event.filter));
    add(const TaskListLoadRequested());
  }
}
```

---

## Cubit Pattern (Basit State İçin)

```dart
// lib/features/settings/presentation/cubit/theme_cubit.dart
@injectable
class ThemeCubit extends Cubit<ThemeMode> {
  final GetThemePreference _getThemePreference;
  final SaveThemePreference _saveThemePreference;

  ThemeCubit({
    required GetThemePreference getThemePreference,
    required SaveThemePreference saveThemePreference,
  })  : _getThemePreference = getThemePreference,
        _saveThemePreference = saveThemePreference,
        super(ThemeMode.system);

  Future<void> loadTheme() async {
    final result = await _getThemePreference();
    result.fold(
      (_) {},
      (themeMode) => emit(themeMode),
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    await _saveThemePreference(SaveThemeParams(mode: mode));
  }
}
```

---

## Event Transformer'lar

```dart
import 'package:bloc_concurrency/bloc_concurrency.dart';

// Arama için debounce
on<SearchQueryChanged>(
  _onSearchQueryChanged,
  transformer: debounce(const Duration(milliseconds: 300)),
);

// Pagination için drop (birden fazla concurrent request'i engelle)
on<NextPageRequested>(
  _onNextPageRequested,
  transformer: droppable(),
);

// Her event'i sırayla işle
on<ItemUpdated>(
  _onItemUpdated,
  transformer: sequential(),
);

// Sadece son event'i işle (restart)
on<FilterChanged>(
  _onFilterChanged,
  transformer: restartable(),
);

// Custom debounce transformer
EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) {
    return events
        .debounceTime(duration)
        .switchMap(mapper);
  };
}
```

---

## Multi-Bloc İletişim

```dart
// Bloc-to-Bloc: StreamSubscription ile
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  late final StreamSubscription _cartSubscription;

  OrderBloc({required CartBloc cartBloc}) : super(const OrderState()) {
    _cartSubscription = cartBloc.stream.listen((cartState) {
      if (cartState.status == CartStatus.updated) {
        add(OrderCartUpdated(items: cartState.items));
      }
    });
  }

  @override
  Future<void> close() {
    _cartSubscription.cancel();
    return super.close();
  }
}

// Widget seviyesinde: BlocListener ile
BlocListener<AuthBloc, AuthState>(
  listenWhen: (prev, curr) =>
    prev.isAuthenticated && !curr.isAuthenticated,
  listener: (context, state) {
    // Logout olunca cart'ı temizle
    context.read<CartBloc>().add(const CartClearRequested());
    context.go('/login');
  },
  child: const SizedBox.shrink(),
)
```

---

## Best Practices

1. **State'i normalize et** — nested object yerine flat state + ID reference
2. **Optimistic update** — server cevabını beklemeden UI'ı güncelle
3. **Debounce arama** — her tuşa basışta API çağırma
4. **Pagination'da droppable** — aynı anda birden fazla sayfa isteme
5. **Bloc event isimlendirmesi** — geçmiş zaman: `Requested`, `Toggled`, `Changed`
6. **State status enum** — `initial`, `loading`, `success`, `failure`
7. **buildWhen/listenWhen** — gereksiz rebuild/listen'ı engelle
8. **Cubit'te emit sonrası işlem yapma** — emit synchronous, sonrası garanti değil
