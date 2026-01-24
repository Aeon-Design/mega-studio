#!/usr/bin/env python3
"""
Test Generator Script
Kullanım: python generate_tests.py --type unit --class UserRepository

Bu script farklı test türleri için boilerplate oluşturur.
"""

import argparse
import re
from pathlib import Path

def to_snake_case(name: str) -> str:
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

UNIT_TEST_TEMPLATE = '''import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

// TODO: Import your class and dependencies
// import 'package:your_app/path/to/{class_snake}.dart';

// Mocks
// class Mock{dependency} extends Mock implements {dependency} {{}}

void main() {{
  group('{class_name}', () {{
    // late {class_name} sut; // System Under Test
    // late Mock{dependency} mock{dependency};
    
    setUp(() {{
      // mock{dependency} = Mock{dependency}();
      // sut = {class_name}(mock{dependency});
    }});
    
    group('methodName', () {{
      test('should return expected result when condition is met', () async {{
        // Arrange
        // when(() => mock{dependency}.someMethod()).thenReturn(value);
        
        // Act
        // final result = await sut.methodName();
        
        // Assert
        // expect(result, expectedValue);
        // verify(() => mock{dependency}.someMethod()).called(1);
      }});
      
      test('should handle error case', () async {{
        // Arrange
        // when(() => mock{dependency}.someMethod()).thenThrow(Exception());
        
        // Act
        // final result = await sut.methodName();
        
        // Assert
        // expect(result.isLeft(), true);
      }});
    }});
  }});
}}
'''

WIDGET_TEST_TEMPLATE = '''import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// TODO: Import your widget
// import 'package:your_app/path/to/{class_snake}.dart';

void main() {{
  group('{class_name}', () {{
    Widget createTestWidget({{Widget? child}}) {{
      return MaterialApp(
        home: Scaffold(
          body: child ?? const {class_name}(),
        ),
      );
    }}
    
    testWidgets('renders correctly', (tester) async {{
      await tester.pumpWidget(createTestWidget());
      
      // Assert initial state
      expect(find.byType({class_name}), findsOneWidget);
    }});
    
    testWidgets('shows loading state', (tester) async {{
      await tester.pumpWidget(createTestWidget());
      
      // Assert loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    }});
    
    testWidgets('shows data when loaded', (tester) async {{
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Assert loaded state
      // expect(find.text('Expected text'), findsOneWidget);
    }});
    
    testWidgets('handles tap interaction', (tester) async {{
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Assert
      // expect(find.text('Clicked'), findsOneWidget);
    }});
    
    testWidgets('handles error state', (tester) async {{
      await tester.pumpWidget(createTestWidget());
      
      // Assert error
      // expect(find.text('Error message'), findsOneWidget);
      // expect(find.text('Retry'), findsOneWidget);
    }});
  }});
}}
'''

GOLDEN_TEST_TEMPLATE = '''import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

// TODO: Import your widget
// import 'package:your_app/path/to/{class_snake}.dart';

void main() {{
  group('{class_name} Golden Tests', () {{
    testGoldens('{class_snake} - default state', (tester) async {{
      await loadAppFonts();
      
      await tester.pumpWidgetBuilder(
        const {class_name}(),
        wrapper: materialAppWrapper(
          theme: ThemeData.light(),
        ),
      );
      
      await screenMatchesGolden(tester, '{class_snake}_default');
    }});
    
    testGoldens('{class_snake} - dark mode', (tester) async {{
      await loadAppFonts();
      
      await tester.pumpWidgetBuilder(
        const {class_name}(),
        wrapper: materialAppWrapper(
          theme: ThemeData.dark(),
        ),
      );
      
      await screenMatchesGolden(tester, '{class_snake}_dark');
    }});
    
    testGoldens('{class_snake} - all states', (tester) async {{
      await loadAppFonts();
      
      final builder = GoldenBuilder.grid(
        columns: 2,
        widthToHeightRatio: 1.5,
      )
        ..addScenario('Default', const {class_name}())
        ..addScenario('Loading', const {class_name}(/* loading state */))
        ..addScenario('Error', const {class_name}(/* error state */))
        ..addScenario('Empty', const {class_name}(/* empty state */));
      
      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: materialAppWrapper(),
      );
      
      await screenMatchesGolden(tester, '{class_snake}_all_states');
    }});
    
    testGoldens('{class_snake} - responsive', (tester) async {{
      await loadAppFonts();
      
      await tester.pumpWidgetBuilder(
        const {class_name}(),
        wrapper: materialAppWrapper(),
      );
      
      await multiScreenGolden(
        tester,
        '{class_snake}_responsive',
        devices: [
          Device.phone,
          Device.iphone11,
          Device.tabletPortrait,
        ],
      );
    }});
  }});
}}
'''

INTEGRATION_TEST_TEMPLATE = '''import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// TODO: Import your app
// import 'package:your_app/main.dart' as app;

void main() {{
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('{class_name} Integration Tests', () {{
    testWidgets('complete user flow', (tester) async {{
      // Launch app
      // app.main();
      // await tester.pumpAndSettle();

      // Step 1: Verify initial state
      // expect(find.text('Welcome'), findsOneWidget);

      // Step 2: Perform action
      // await tester.tap(find.byKey(const Key('action_button')));
      // await tester.pumpAndSettle();

      // Step 3: Verify result
      // expect(find.text('Success'), findsOneWidget);

      // Step 4: Navigate
      // await tester.tap(find.byIcon(Icons.arrow_forward));
      // await tester.pumpAndSettle();

      // Step 5: Verify navigation
      // expect(find.byType(NextScreen), findsOneWidget);
    }});

    testWidgets('error handling flow', (tester) async {{
      // Test error scenarios
    }});

    testWidgets('edge cases', (tester) async {{
      // Test edge cases
    }});
  }});
}}
'''

def generate_test(test_type: str, class_name: str, output_dir: str = '.'):
    """Test dosyası oluştur"""
    class_snake = to_snake_case(class_name)
    
    templates = {
        'unit': UNIT_TEST_TEMPLATE,
        'widget': WIDGET_TEST_TEMPLATE,
        'golden': GOLDEN_TEST_TEMPLATE,
        'integration': INTEGRATION_TEST_TEMPLATE,
    }
    
    if test_type not in templates:
        print(f'❌ Unknown test type: {test_type}')
        print(f'   Available: {", ".join(templates.keys())}')
        return
    
    template = templates[test_type]
    content = template.format(class_name=class_name, class_snake=class_snake)
    
    # Determine output path
    if test_type == 'integration':
        test_path = Path(output_dir) / 'integration_test'
    else:
        test_path = Path(output_dir) / 'test'
    
    test_path.mkdir(parents=True, exist_ok=True)
    
    suffix = '_test' if test_type != 'golden' else '_golden_test'
    filename = f'{class_snake}{suffix}.dart'
    filepath = test_path / filename
    
    filepath.write_text(content, encoding='utf-8')
    
    print(f'\n✅ Created {test_type} test: {filepath}')
    print(f'\n💡 Tips:')
    if test_type == 'unit':
        print('  - Focus on testing business logic')
        print('  - Use mocktail for mocking dependencies')
        print('  - Follow AAA pattern (Arrange, Act, Assert)')
    elif test_type == 'widget':
        print('  - Test widget rendering and interactions')
        print('  - Use pumpAndSettle for animations')
        print('  - Test all widget states')
    elif test_type == 'golden':
        print('  - Run: flutter test --update-goldens')
        print('  - Install golden_toolkit package')
        print('  - Load fonts before testing')
    elif test_type == 'integration':
        print('  - Run: flutter test integration_test')
        print('  - Test complete user flows')
        print('  - Use real device/emulator')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate test files')
    parser.add_argument('--type', required=True, 
                        choices=['unit', 'widget', 'golden', 'integration'],
                        help='Test type')
    parser.add_argument('--class', dest='class_name', required=True,
                        help='Class name to test')
    parser.add_argument('--output', default='.', help='Output directory')
    
    args = parser.parse_args()
    generate_test(args.type, args.class_name, args.output)
