---
name: "Testing Mastery"
version: "1.0.0"
description: |
  Flutter için kapsamlı test stratejileri ve implementasyonları.
  Test yazma, coverage artırma veya test mimarisi gerektiğinde tetiklenir.
  Tetikleyiciler: "test yaz", "unit test", "widget test", "golden test",
  "integration test", "mocktail", "bloc_test", "coverage", "test pyramid"
primary_users:
  - flutter-testing-agent
  - qa-lead
  - mobile-developer
dependencies:
  - flutter-foundations
tags:
  - testing
  - quality
  - core
scripts:
  - scripts/generate_tests.py
---

# 🧪 Testing Mastery

## Quick Start

%95 coverage hedefi ile kaliteli test yazma. Test piramidini takip et:
Unit (50%) → Widget (30%) → Integration (15%) → E2E (5%)

---

## 📚 Core Concepts

### 1. Test Piramidi

```
        ┌─────────┐
        │   E2E   │      ~5%   (Slow, Expensive)
        │  Tests  │      • Full app flow
       ───────────────
      │  Integration  │   ~15%  (Medium)
      │    Tests      │   • Multiple widgets
     ─────────────────────
    │    Widget Tests     │   ~30%  (Fast)
    │                     │   • Single widget
   ───────────────────────────
  │      Unit Tests           │  ~50%  (Fastest)
  │                           │  • Single function/class
 ─────────────────────────────────
```

### 2. Unit Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

// Mock sınıfları
class MockUserRepository extends Mock implements UserRepository {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

// Test
void main() {
  late GetUserProfile useCase;
  late MockUserRepository mockRepository;
  
  setUp(() {
    mockRepository = MockUserRepository();
    useCase = GetUserProfile(mockRepository);
  });
  
  // Grup: Anlamlı isimlendirme
  group('GetUserProfile', () {
    const tUserId = 'user-123';
    final tUser = User(id: tUserId, name: 'Test', email: 'test@test.com');
    
    test('should return User when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.getUserById(any()))
          .thenAnswer((_) async => Right(tUser));
      
      // Act
      final result = await useCase(GetUserProfileParams(userId: tUserId));
      
      // Assert
      expect(result, Right(tUser));
      verify(() => mockRepository.getUserById(tUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
    
    test('should return ServerFailure when repository fails', () async {
      // Arrange
      when(() => mockRepository.getUserById(any()))
          .thenAnswer((_) async => Left(ServerFailure('error')));
      
      // Act
      final result = await useCase(GetUserProfileParams(userId: tUserId));
      
      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });
}
```

### 3. Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockUserNotifier extends Mock implements UserNotifier {}

void main() {
  late MockUserNotifier mockNotifier;
  
  // Test widget wrapper
  Widget createTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        userNotifierProvider.overrideWith(() => mockNotifier),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }
  
  setUp(() {
    mockNotifier = MockUserNotifier();
  });
  
  group('UserProfilePage', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      // Arrange
      when(() => mockNotifier.state).thenReturn(UserState.loading());
      
      // Act
      await tester.pumpWidget(createTestWidget(const UserProfilePage()));
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('shows user data when loaded', (tester) async {
      // Arrange
      final user = User(id: '1', name: 'John', email: 'john@test.com');
      when(() => mockNotifier.state).thenReturn(UserState.loaded(user));
      
      // Act
      await tester.pumpWidget(createTestWidget(const UserProfilePage()));
      
      // Assert
      expect(find.text('John'), findsOneWidget);
      expect(find.text('john@test.com'), findsOneWidget);
    });
    
    testWidgets('calls refresh on pull down', (tester) async {
      // Arrange
      when(() => mockNotifier.state).thenReturn(UserState.loaded(testUser));
      when(() => mockNotifier.refresh()).thenAnswer((_) async {});
      
      // Act
      await tester.pumpWidget(createTestWidget(const UserProfilePage()));
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      
      // Assert
      verify(() => mockNotifier.refresh()).called(1);
    });
    
    testWidgets('navigates to edit page on button tap', (tester) async {
      // Arrange
      when(() => mockNotifier.state).thenReturn(UserState.loaded(testUser));
      
      // Act
      await tester.pumpWidget(createTestWidget(const UserProfilePage()));
      await tester.tap(find.byKey(const Key('edit_button')));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.byType(EditProfilePage), findsOneWidget);
    });
  });
}
```

### 4. Golden Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  group('UserCard Golden Tests', () {
    testGoldens('UserCard - all states', (tester) async {
      await loadAppFonts(); // Fontları yükle!
      
      final builder = GoldenBuilder.grid(
        columns: 2,
        widthToHeightRatio: 1.5,
      )
        ..addScenario('Default', UserCard(user: User.sample()))
        ..addScenario('Verified', UserCard(user: User.sample(isVerified: true)))
        ..addScenario('Premium', UserCard(user: User.sample(isPremium: true)))
        ..addScenario('Long Name', UserCard(
          user: User.sample(name: 'Very Long Username That Should Truncate'),
        ));
      
      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: materialAppWrapper(theme: AppTheme.light),
      );
      
      await screenMatchesGolden(tester, 'user_card_all_states');
    });
    
    testGoldens('UserCard - dark mode', (tester) async {
      await loadAppFonts();
      
      await tester.pumpWidgetBuilder(
        UserCard(user: User.sample()),
        wrapper: materialAppWrapper(theme: AppTheme.dark),
      );
      
      await screenMatchesGolden(tester, 'user_card_dark');
    });
    
    testGoldens('Responsive layouts', (tester) async {
      await loadAppFonts();
      
      final devices = [
        Device.phone,
        Device.iphone11,
        Device.tabletPortrait,
      ];
      
      await tester.pumpWidgetBuilder(
        const HomePage(),
        wrapper: materialAppWrapper(),
      );
      
      await multiScreenGolden(tester, 'home_page_responsive', devices: devices);
    });
  });
}

// Golden baseline güncelleme:
// flutter test --update-goldens
```

### 5. Integration Test

```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('App E2E Tests', () {
    testWidgets('complete user flow: login -> view profile -> logout',
        (tester) async {
      // Launch app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // Step 1: Login
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      
      // Verify: Home page visible
      expect(find.byType(HomePage), findsOneWidget);
      
      // Step 2: Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Verify: Profile page
      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      
      // Step 3: Logout
      await tester.tap(find.text('Çıkış Yap'));
      await tester.pumpAndSettle();
      
      // Confirm dialog
      await tester.tap(find.text('Evet'));
      await tester.pumpAndSettle();
      
      // Verify: Back to login
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}

// Çalıştırma:
// flutter test integration_test/app_test.dart
```

### 6. BLoC Test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetUsers extends Mock implements GetUsers {}

void main() {
  late UsersBloc bloc;
  late MockGetUsers mockGetUsers;
  
  setUp(() {
    mockGetUsers = MockGetUsers();
    bloc = UsersBloc(getUsers: mockGetUsers);
  });
  
  tearDown(() {
    bloc.close();
  });
  
  test('initial state is UsersInitial', () {
    expect(bloc.state, equals(UsersInitial()));
  });
  
  blocTest<UsersBloc, UsersState>(
    'emits [Loading, Loaded] when LoadUsers succeeds',
    build: () {
      when(() => mockGetUsers(any()))
          .thenAnswer((_) async => Right(testUsers));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadUsers()),
    expect: () => [
      UsersLoading(),
      UsersLoaded(users: testUsers),
    ],
    verify: (_) {
      verify(() => mockGetUsers(const NoParams())).called(1);
    },
  );
  
  blocTest<UsersBloc, UsersState>(
    'emits [Loading, Error] when LoadUsers fails',
    build: () {
      when(() => mockGetUsers(any()))
          .thenAnswer((_) async => Left(ServerFailure('error')));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadUsers()),
    expect: () => [
      UsersLoading(),
      const UsersError(message: 'error'),
    ],
  );
}
```

---

## ✅ Testing Checklist

### Coverage
- [ ] Line coverage ≥ 95%
- [ ] Branch coverage ≥ 90%
- [ ] All public methods tested

### Unit Tests
- [ ] Use cases tested
- [ ] Repository implementations tested
- [ ] Edge cases covered
- [ ] Error scenarios tested

### Widget Tests
- [ ] All states tested (loading, error, success, empty)
- [ ] User interactions tested
- [ ] Navigation tested

### Golden Tests
- [ ] Key components have goldens
- [ ] Dark mode variants
- [ ] Responsive breakpoints

---

## ⚠️ Common Mistakes

### 1. Flaky Tests
```dart
// ❌ FLAKY - Random data
test('user list', () {
  final users = generateRandomUsers();
  expect(users.length > 0, true);
});

// ✅ DETERMINISTIC
test('user list', () {
  final users = [User.sample(), User.sample()];
  expect(users.length, 2);
});
```

### 2. Missing pumpAndSettle
```dart
// ❌ Animation tamamlanmadan kontrol
await tester.tap(find.byType(Button));
expect(find.byType(NextPage), findsOneWidget);

// ✅ Animation bekle
await tester.tap(find.byType(Button));
await tester.pumpAndSettle(); // Tüm frame'ler tamamlansın
expect(find.byType(NextPage), findsOneWidget);
```

---

## 🔗 Related Resources

- [examples/unit_test.dart](examples/unit_test.dart)
- [examples/widget_test.dart](examples/widget_test.dart)
- [examples/golden_test.dart](examples/golden_test.dart)
- Grimoire: `flutter_testing.md`
