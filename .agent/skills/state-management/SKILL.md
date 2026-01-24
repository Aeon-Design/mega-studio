---
name: "State Management"
version: "1.0.0"
description: |
  Flutter projelerinde Bloc ve Riverpod state management implementasyonu.
  State yönetimi, provider, cubit veya bloc kullanımı gerektiğinde tetiklenir.
  Tetikleyiciler: "state management", "bloc", "cubit", "riverpod", "provider",
  "notifier", "async notifier", "event", "emit", "watch", "read", "ref"
primary_users:
  - state-manager
  - mobile-developer
dependencies:
  - flutter-foundations
  - clean-architecture
tags:
  - state
  - core
  - riverpod
  - bloc
scripts:
  - scripts/create_bloc.py
---

# 🔄 State Management

## Quick Start

State management seçimi projenin ölçeğine ve ekip tercihine bağlıdır.
**Riverpod:** Flexibility, compile-safety, minimal boilerplate
**Bloc:** Enterprise, event-driven, explicit state transitions

---

## 📚 Karar Ağacı

```
State Management Seçimi:
│
├─► Küçük proje, hızlı prototip
│   └─► Provider veya Riverpod (basit)
│
├─► Orta/büyük proje, ekip çalışması
│   └─► Riverpod veya Bloc
│       ├─► Event-driven tercih → Bloc
│       └─► Reactive/functional tercih → Riverpod
│
├─► Enterprise, strict patterns gerekli
│   └─► Bloc (explicit events, states)
│
└─► Existing React/Redux deneyimi
    └─► Bloc veya Redux
```

---

## 🔷 RIVERPOD

### 1. Temel Kurulum

```dart
// pubspec.yaml
dependencies:
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

dev_dependencies:
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.8
```

### 2. Provider Türleri

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

// 1️⃣ Simple Provider (computed value)
@riverpod
String greeting(GreetingRef ref) {
  final user = ref.watch(userProvider);
  return 'Merhaba, ${user.name}!';
}

// 2️⃣ FutureProvider (async data)
@riverpod
Future<List<Task>> tasks(TasksRef ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getAllTasks();
}

// 3️⃣ StreamProvider (real-time data)
@riverpod
Stream<List<Message>> messages(MessagesRef ref) {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.watchMessages();
}

// 4️⃣ Notifier (mutable state)
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  
  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

// 5️⃣ AsyncNotifier (async + mutable)
@riverpod
class TaskList extends _$TaskList {
  @override
  Future<List<Task>> build() async {
    return ref.watch(taskRepositoryProvider).getAllTasks();
  }
  
  Future<void> addTask(Task task) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(taskRepositoryProvider).createTask(task);
      return ref.read(taskRepositoryProvider).getAllTasks();
    });
  }
  
  Future<void> deleteTask(String id) async {
    // Optimistic update
    final previousState = state;
    state = AsyncData(
      state.value!.where((t) => t.id != id).toList(),
    );
    
    try {
      await ref.read(taskRepositoryProvider).deleteTask(id);
    } catch (e) {
      state = previousState; // Rollback
      rethrow;
    }
  }
}
```

### 3. Widget Kullanımı

```dart
// ConsumerWidget
class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);
    
    return tasksAsync.when(
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorWidget(error: error),
      data: (tasks) => ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) => TaskCard(task: tasks[index]),
      ),
    );
  }
}

// HookConsumerWidget (with flutter_hooks)
class CounterPage extends HookConsumerWidget {
  const CounterPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    final animController = useAnimationController(duration: 300.ms);
    
    return Column(
      children: [
        Text('Count: $counter'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).increment(),
          child: const Text('Artır'),
        ),
      ],
    );
  }
}

// Selective rebuild
class UserAvatar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sadece avatarUrl değiştiğinde rebuild
    final avatarUrl = ref.watch(
      userProvider.select((user) => user.avatarUrl),
    );
    
    return CircleAvatar(backgroundImage: NetworkImage(avatarUrl));
  }
}
```

### 4. Family (Parametreli Provider)

```dart
@riverpod
Future<Task> taskById(TaskByIdRef ref, String taskId) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTaskById(taskId);
}

// Kullanım
final task = ref.watch(taskByIdProvider('task-123'));
```

---

## 🟦 BLOC

### 1. Temel Kurulum

```dart
// pubspec.yaml
dependencies:
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
  freezed_annotation: ^2.4.1

dev_dependencies:
  bloc_test: ^9.1.5
  freezed: ^2.4.6
  build_runner: ^2.4.8
```

### 2. State Modelleme (freezed)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_state.freezed.dart';

@freezed
class TaskState with _$TaskState {
  const factory TaskState.initial() = TaskInitial;
  const factory TaskState.loading() = TaskLoading;
  const factory TaskState.loaded({
    required List<Task> tasks,
    @Default(false) bool isRefreshing,
  }) = TaskLoaded;
  const factory TaskState.error({required String message}) = TaskError;
}
```

### 3. Event Tanımlama

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_event.freezed.dart';

@freezed
class TaskEvent with _$TaskEvent {
  const factory TaskEvent.load() = LoadTasks;
  const factory TaskEvent.refresh() = RefreshTasks;
  const factory TaskEvent.add({required Task task}) = AddTask;
  const factory TaskEvent.delete({required String id}) = DeleteTask;
  const factory TaskEvent.toggleComplete({required String id}) = ToggleComplete;
}
```

### 4. Bloc Implementation

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  final CreateTask createTask;
  final DeleteTask deleteTask;
  
  TaskBloc({
    required this.getTasks,
    required this.createTask,
    required this.deleteTask,
  }) : super(const TaskState.initial()) {
    on<LoadTasks>(_onLoad);
    on<RefreshTasks>(_onRefresh);
    on<AddTask>(_onAdd);
    on<DeleteTask>(_onDelete);
  }
  
  Future<void> _onLoad(LoadTasks event, Emitter<TaskState> emit) async {
    emit(const TaskState.loading());
    
    final result = await getTasks(const NoParams());
    
    result.fold(
      (failure) => emit(TaskState.error(message: failure.message)),
      (tasks) => emit(TaskState.loaded(tasks: tasks)),
    );
  }
  
  Future<void> _onRefresh(RefreshTasks event, Emitter<TaskState> emit) async {
    // Keep current data while refreshing
    final currentState = state;
    if (currentState is TaskLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    }
    
    final result = await getTasks(const NoParams());
    
    result.fold(
      (failure) => emit(TaskState.error(message: failure.message)),
      (tasks) => emit(TaskState.loaded(tasks: tasks)),
    );
  }
  
  Future<void> _onAdd(AddTask event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;
    
    // Optimistic update
    final optimisticList = [...currentState.tasks, event.task];
    emit(currentState.copyWith(tasks: optimisticList));
    
    final result = await createTask(CreateTaskParams(task: event.task));
    
    result.fold(
      (failure) {
        // Rollback
        emit(currentState);
        // Show error (via separate error state or Cubit)
      },
      (_) {
        // Success - state already updated
      },
    );
  }
  
  Future<void> _onDelete(DeleteTask event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;
    
    final previousList = currentState.tasks;
    final updatedList = previousList.where((t) => t.id != event.id).toList();
    
    emit(currentState.copyWith(tasks: updatedList));
    
    final result = await deleteTask(DeleteTaskParams(id: event.id));
    
    result.fold(
      (failure) => emit(currentState.copyWith(tasks: previousList)),
      (_) {},
    );
  }
}
```

### 5. Widget Kullanımı

```dart
// BlocProvider
class TaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TaskBloc>()..add(const LoadTasks()),
      child: const TaskListPage(),
    );
  }
}

// BlocBuilder
class TaskListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const LoadingIndicator(),
          loaded: (tasks, isRefreshing) => TaskListView(tasks: tasks),
          error: (message) => ErrorView(message: message),
        );
      },
    );
  }
}

// BlocListener (side effects)
BlocListener<TaskBloc, TaskState>(
  listenWhen: (previous, current) => current is TaskError,
  listener: (context, state) {
    if (state is TaskError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: child,
)

// BlocConsumer (builder + listener)
BlocConsumer<TaskBloc, TaskState>(
  listener: (context, state) {
    // Side effects
  },
  builder: (context, state) {
    // UI
  },
)

// Selective rebuild with buildWhen
BlocBuilder<TaskBloc, TaskState>(
  buildWhen: (previous, current) {
    // Sadece task sayısı değiştiğinde rebuild
    if (previous is TaskLoaded && current is TaskLoaded) {
      return previous.tasks.length != current.tasks.length;
    }
    return true;
  },
  builder: (context, state) => TaskCounter(),
)
```

---

## ✅ Checklist

### Riverpod
- [ ] Tüm provider'lar code generation kullanıyor mu?
- [ ] ref.watch vs ref.read doğru kullanılıyor mu?
- [ ] AsyncValue.when ile tüm durumlar handle ediliyor mu?

### Bloc
- [ ] State'ler freezed ile tanımlı mı?
- [ ] Event'ler açık ve anlamlı mı?
- [ ] Optimistic update düşünüldü mü?
- [ ] Error handling var mı?

---

## ⚠️ Common Mistakes

### 1. ref.read in build
```dart
// ❌ YANLIŞ - Reactive değil
Widget build(context, ref) {
  final value = ref.read(provider); // Değişiklikte rebuild olmaz!
  return Text(value);
}

// ✅ DOĞRU
Widget build(context, ref) {
  final value = ref.watch(provider);
  return Text(value);
}
```

### 2. Bloc'ta emit after async gap
```dart
// ❌ HATA RİSKİ
Future<void> _onLoad(event, emit) async {
  emit(Loading());
  final data = await repository.getData();
  emit(Loaded(data)); // Bloc kapanmış olabilir!
}

// ✅ SAFE with isClosed check (veya kullanma, Bloc 8+ hallediyor)
```

---

## 🔗 Related Resources

- [patterns/riverpod/examples.dart](patterns/riverpod/examples.dart)
- [patterns/bloc/examples.dart](patterns/bloc/examples.dart)
- [decision_tree.md](decision_tree.md)
- Grimoire: `flutter_state_riverpod.md`
