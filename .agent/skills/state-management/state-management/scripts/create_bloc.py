#!/usr/bin/env python3
"""
Bloc Generator Script
Kullanım: python create_bloc.py --name TaskList --feature tasks

Bu script Bloc, Event ve State dosyaları oluşturur.
"""

import argparse
import os
import re
from pathlib import Path

def to_snake_case(name: str) -> str:
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

def to_pascal_case(name: str) -> str:
    return ''.join(word.capitalize() for word in name.replace('-', '_').split('_'))

BLOC_TEMPLATE = '''import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '{name_snake}_bloc.freezed.dart';
part '{name_snake}_event.dart';
part '{name_snake}_state.dart';

class {name_pascal}Bloc extends Bloc<{name_pascal}Event, {name_pascal}State> {{
  {name_pascal}Bloc() : super(const {name_pascal}State.initial()) {{
    on<{name_pascal}Event>((event, emit) async {{
      await event.map(
        started: (e) async => _onStarted(e, emit),
        loaded: (e) async => _onLoaded(e, emit),
      );
    }});
  }}

  Future<void> _onStarted(
    _Started event,
    Emitter<{name_pascal}State> emit,
  ) async {{
    emit(const {name_pascal}State.loading());
    // TODO: Implement business logic
    await Future.delayed(const Duration(seconds: 1));
    emit(const {name_pascal}State.loaded(items: []));
  }}

  Future<void> _onLoaded(
    _Loaded event,
    Emitter<{name_pascal}State> emit,
  ) async {{
    emit({name_pascal}State.loaded(items: event.items));
  }}
}}
'''

EVENT_TEMPLATE = '''part of '{name_snake}_bloc.dart';

@freezed
class {name_pascal}Event with _${name_pascal}Event {{
  const factory {name_pascal}Event.started() = _Started;
  const factory {name_pascal}Event.loaded({{required List<dynamic> items}}) = _Loaded;
}}
'''

STATE_TEMPLATE = '''part of '{name_snake}_bloc.dart';

@freezed
class {name_pascal}State with _${name_pascal}State {{
  const factory {name_pascal}State.initial() = _Initial;
  const factory {name_pascal}State.loading() = _Loading;
  const factory {name_pascal}State.loaded({{
    required List<dynamic> items,
    @Default(false) bool isRefreshing,
  }}) = _Loaded;
  const factory {name_pascal}State.error({{required String message}}) = _Error;
}}
'''

TEST_TEMPLATE = '''import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// TODO: Import your bloc
// import '{name_snake}_bloc.dart';

void main() {{
  group('{name_pascal}Bloc', () {{
    late {name_pascal}Bloc bloc;

    setUp(() {{
      bloc = {name_pascal}Bloc();
    }});

    tearDown(() {{
      bloc.close();
    }});

    test('initial state is correct', () {{
      expect(bloc.state, const {name_pascal}State.initial());
    }});

    blocTest<{name_pascal}Bloc, {name_pascal}State>(
      'emits [loading, loaded] when started is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const {name_pascal}Event.started()),
      expect: () => [
        const {name_pascal}State.loading(),
        const {name_pascal}State.loaded(items: []),
      ],
    );

    blocTest<{name_pascal}Bloc, {name_pascal}State>(
      'emits [loaded] when loaded is added',
      build: () => bloc,
      seed: () => const {name_pascal}State.loading(),
      act: (bloc) => bloc.add(const {name_pascal}Event.loaded(items: ['test'])),
      expect: () => [
        const {name_pascal}State.loaded(items: ['test']),
      ],
    );
  }});
}}
'''

def create_bloc(name: str, feature: str, output_dir: str = '.', with_test: bool = True):
    """Bloc dosyalarını oluştur"""
    name_snake = to_snake_case(name)
    name_pascal = to_pascal_case(name)
    
    print(f'\n🔷 Creating Bloc: {name_pascal}')
    print('=' * 50)
    
    context = {'name_snake': name_snake, 'name_pascal': name_pascal}
    
    # Paths
    if feature:
        bloc_path = Path(output_dir) / 'lib' / 'features' / feature / 'presentation' / 'bloc'
        test_path = Path(output_dir) / 'test' / 'features' / feature / 'presentation' / 'bloc'
    else:
        bloc_path = Path(output_dir) / 'lib' / 'bloc'
        test_path = Path(output_dir) / 'test' / 'bloc'
    
    bloc_path.mkdir(parents=True, exist_ok=True)
    
    # Write files
    files = [
        (bloc_path / f'{name_snake}_bloc.dart', BLOC_TEMPLATE.format(**context)),
        (bloc_path / f'{name_snake}_event.dart', EVENT_TEMPLATE.format(**context)),
        (bloc_path / f'{name_snake}_state.dart', STATE_TEMPLATE.format(**context)),
    ]
    
    for path, content in files:
        path.write_text(content, encoding='utf-8')
        print(f'  ✓ Created: {path}')
    
    if with_test:
        test_path.mkdir(parents=True, exist_ok=True)
        test_file = test_path / f'{name_snake}_bloc_test.dart'
        test_file.write_text(TEST_TEMPLATE.format(**context), encoding='utf-8')
        print(f'  ✓ Created: {test_file}')
    
    print('\n' + '=' * 50)
    print(f'✅ Bloc "{name_pascal}" created!')
    print('\n⚡ Next: flutter pub run build_runner build --delete-conflicting-outputs')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Create a new Bloc')
    parser.add_argument('--name', required=True, help='Bloc name (e.g., TaskList)')
    parser.add_argument('--feature', default='', help='Feature name (e.g., tasks)')
    parser.add_argument('--output', default='.', help='Output directory')
    parser.add_argument('--no-test', action='store_true', help='Skip test generation')
    
    args = parser.parse_args()
    create_bloc(args.name, args.feature, args.output, not args.no_test)
