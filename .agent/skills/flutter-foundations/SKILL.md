# 🏗️ Flutter Foundations Skill

> Widget yapısı, lifecycle, navigation ve temel Flutter prensipleri

---

## Widget Ağacı ve Render Pipeline

### Build → Layout → Paint → Composite
```
1. BUILD:   Widget ağacı oluşturulur (build() çağrılır)
2. LAYOUT:  Her RenderObject boyutunu ve pozisyonunu hesaplar
3. PAINT:   Her RenderObject kendini Canvas'a çizer
4. COMPOSITE: Layer'lar GPU'ya gönderilir
```

### Widget vs Element vs RenderObject
```
Widget (immutable config)     → "Ne istiyorum" (blueprint)
Element (mutable lifecycle)   → "Ne var" (instance)
RenderObject (layout/paint)   → "Nasıl çizilir" (renderer)

Widget ağacı yeniden build edildiğinde:
1. Flutter eski ve yeni Widget'ı karşılaştırır (runtimeType + key)
2. Aynıysa → Element güncellenir (rebuild yok)
3. Farklıysa → Eski Element kaldırılır, yeni oluşturulur
```

### StatelessWidget vs StatefulWidget Karar Ağacı
```
Widget'ın durumu değişecek mi?
├── Hayır → StatelessWidget
│   ├── Sadece gelen veriyi gösteriyor → StatelessWidget
│   ├── Const constructor kullanılabilir → const StatelessWidget ✅
│   └── AnimationController gerekli → StatefulWidget'a geç
│
└── Evet → Bloc/Cubit kullan (setState yerine)
    ├── Form state (TextEditingController) → StatefulWidget (sadece dispose için)
    ├── AnimationController → StatefulWidget (Ticker mixin)
    ├── TabController → StatefulWidget
    └── Diğer her şey → BlocBuilder/BlocListener
```

---

## Lifecycle (StatefulWidget)

```dart
class _MyWidgetState extends State<MyWidget> {
  // 1. Constructor çağrılır

  @override
  void initState() {
    super.initState();
    // 2. Bir kez çağrılır — Bloc event tetikle, listener ekle
    // ❌ ASLA: setState, context.read, async çağrı
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 3. initState sonrası + InheritedWidget değiştiğinde
    // ✅ BURADA: MediaQuery, Theme, Localizations erişimi
  }

  @override
  void didUpdateWidget(covariant MyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 4. Parent yeniden build edip yeni Widget verdiğinde
    // ✅ BURADA: Prop değişikliğine tepki ver
  }

  @override
  Widget build(BuildContext context) {
    // 5. Her rebuild'de çağrılır — PURE olmalı, side-effect yok
    return Container();
  }

  @override
  void deactivate() {
    super.deactivate();
    // 6. Element ağaçtan çıkarıldığında (geçici)
  }

  @override
  void dispose() {
    // 7. Kalıcı olarak kaldırıldığında
    // ✅ BURADA: Controller.dispose(), subscription.cancel()
    super.dispose();
  }
}
```

---

## Navigation (GoRouter)

### Temel Kurulum
```dart
// lib/app/router.dart
import 'package:go_router/go_router.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: kDebugMode,
  redirect: _globalRedirect,
  routes: [
    // Shell route — ortak layout (bottom nav)
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (context, state) => const SearchPage(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
          routes: [
            GoRoute(
              path: 'edit',
              name: 'profile-edit',
              builder: (context, state) => const ProfileEditPage(),
            ),
          ],
        ),
      ],
    ),
    // Auth routes (shell dışında)
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
  ],
  errorBuilder: (context, state) => ErrorPage(error: state.error),
);

// Global redirect — auth kontrolü
String? _globalRedirect(BuildContext context, GoRouterState state) {
  final isLoggedIn = context.read<AuthBloc>().state.isAuthenticated;
  final isAuthRoute = state.matchedLocation == '/login';

  if (!isLoggedIn && !isAuthRoute) return '/login';
  if (isLoggedIn && isAuthRoute) return '/';
  return null;
}
```

### Navigation Kullanımı
```dart
// Sayfaya git
context.go('/profile');              // Replace (stack'i temizle)
context.push('/profile/edit');       // Push (stack'e ekle)
context.pop();                       // Geri

// Parametre ile
context.go('/product/123');          // Path parameter
context.goNamed('search', queryParameters: {'q': 'flutter'});

// Veri ile
context.push('/details', extra: myObject);
// Alma:
final data = GoRouterState.of(context).extra as MyObject;
```

---

## Tema Sistemi

### Theme Kurulumu
```dart
// lib/app/theme/app_theme.dart
class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      textTheme: _textTheme,
      // ... dark tema özelleştirmeleri
    );
  }

  static const _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  );
}
```

### Spacing Sistemi
```dart
// lib/app/theme/app_spacing.dart
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Padding presets
  static const paddingAll = EdgeInsets.all(md);
  static const paddingHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const paddingVertical = EdgeInsets.symmetric(vertical: md);
  static const paddingCard = EdgeInsets.all(lg);

  // Gap widget'ları
  static const gapXs = SizedBox(height: xs);
  static const gapSm = SizedBox(height: sm);
  static const gapMd = SizedBox(height: md);
  static const gapLg = SizedBox(height: lg);
  static const gapXl = SizedBox(height: xl);

  static const gapHXs = SizedBox(width: xs);
  static const gapHSm = SizedBox(width: sm);
  static const gapHMd = SizedBox(width: md);
  static const gapHLg = SizedBox(width: lg);
}
```

---

## Yaygın Hatalar ve Çözümleri

### 1. setState kullanılmıyorsa neden rebuild oluyor?
```dart
// Sorun: Gereksiz rebuild
// Parent build olunca tüm children rebuild olur

// Çözüm 1: const constructor
const MyExpensiveWidget()  // const olursa rebuild olmaz

// Çözüm 2: BlocSelector (sadece ilgili kısım değişince rebuild)
BlocSelector<MyBloc, MyState, String>(
  selector: (state) => state.title,  // Sadece title değişince rebuild
  builder: (context, title) => Text(title),
)
```

### 2. Context güvensiz kullanımı
```dart
// ❌ YANLIŞ — async gap sonrası context kullanımı
onTap: () async {
  await someAsyncOperation();
  Navigator.of(context).pop();  // Context artık geçersiz olabilir
}

// ✅ DOĞRU — mounted kontrolü
onTap: () async {
  await someAsyncOperation();
  if (!context.mounted) return;
  Navigator.of(context).pop();
}
```

### 3. Memory leak
```dart
// ❌ YANLIŞ — dispose edilmeyen controller
class _MyState extends State<MyWidget> {
  final controller = TextEditingController();
  late final StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    sub = stream.listen((data) { });
  }
  // dispose yok!
}

// ✅ DOĞRU
@override
void dispose() {
  controller.dispose();
  sub.cancel();
  super.dispose();
}
```
