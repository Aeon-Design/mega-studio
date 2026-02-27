#!/usr/bin/env python3
"""
🏗️ Mega Studio Feature Generator (v8.0)
Generates a full Clean Architecture feature with Bloc, Freezed, Injectable, and Retrofit.

Usage:
  python create_feature.py --name feature_name
"""

import argparse
import os
import re
from pathlib import Path

def to_snake_case(name):
    name = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', name).lower()

def to_pascal_case(name):
    return ''.join(x.title() for x in name.split('_'))

def to_camel_case(name):
    pascal = to_pascal_case(name)
    return pascal[0].lower() + pascal[1:]

class FeatureGenerator:
    def __init__(self, name, project_root="."):
        self.name = to_snake_case(name)
        self.pascal_name = to_pascal_case(self.name)
        self.camel_name = to_camel_case(self.name)
        self.project_root = Path(project_root).resolve()
        self.feature_path = self.project_root / "lib" / "features" / self.name

    def create_structure(self):
        dirs = [
            "data/datasources",
            "data/models",
            "data/repositories",
            "domain/entities",
            "domain/repositories",
            "domain/usecases",
            "presentation/bloc",
            "presentation/pages",
            "presentation/widgets",
        ]
        
        for d in dirs:
            (self.feature_path / d).mkdir(parents=True, exist_ok=True)
            
        print(f"✅ Created directory structure for '{self.name}'")

    def _write(self, path, content):
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content.strip() + '\n')
        print(f"📄 Created {path.name}")

    def generate_domain(self):
        # Entity
        entity_content = f"""
import 'package:equatable/equatable.dart';

class {self.pascal_name} extends Equatable {{
  final String id;
  final String name;

  const {self.pascal_name}({{
    required this.id,
    required this.name,
  }});

  @override
  List<Object?> get props => [id, name];
}}
"""
        self._write(self.feature_path / "domain/entities" / f"{self.name}.dart", entity_content)

        # Repository Interface
        repo_content = f"""
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/{self.name}.dart';

abstract class {self.pascal_name}Repository {{
  Future<Either<Failure, List<{self.pascal_name}>>> get{self.pascal_name}s();
  Future<Either<Failure, {self.pascal_name}>> get{self.pascal_name}(String id);
}}
"""
        self._write(self.feature_path / "domain/repositories" / f"{self.name}_repository.dart", repo_content)

        # UseCase
        usecase_content = f"""
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/{self.name}.dart';
import '../repositories/{self.name}_repository.dart';

@injectable
class Get{self.pascal_name}s implements UseCase<List<{self.pascal_name}>, NoParams> {{
  final {self.pascal_name}Repository _repository;

  Get{self.pascal_name}s(this._repository);

  @override
  Future<Either<Failure, List<{self.pascal_name}>>> call(NoParams params) async {{
    return _repository.get{self.pascal_name}s();
  }}
}}
"""
        self._write(self.feature_path / "domain/usecases" / f"get_{self.name}s.dart", usecase_content)

    def generate_data(self):
        # Model
        model_content = f"""
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/{self.name}.dart';

part '{self.name}_model.freezed.dart';
part '{self.name}_model.g.dart';

@freezed
class {self.pascal_name}Model with _${self.pascal_name}Model {{
  const factory {self.pascal_name}Model({{
    required String id,
    required String name,
  }}) = _{self.pascal_name}Model;

  factory {self.pascal_name}Model.fromJson(Map<String, dynamic> json) =>
      _${self.pascal_name}ModelFromJson(json);
}}

extension {self.pascal_name}ModelX on {self.pascal_name}Model {{
  {self.pascal_name} toEntity() => {self.pascal_name}(id: id, name: name);
}}
"""
        self._write(self.feature_path / "data/models" / f"{self.name}_model.dart", model_content)

        # DataSource
        ds_content = f"""
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import '../models/{self.name}_model.dart';

part '{self.name}_remote_data_source.g.dart';

@RestApi()
@injectable
abstract class {self.pascal_name}RemoteDataSource {{
  @factoryMethod
  factory {self.pascal_name}RemoteDataSource(Dio dio) = _{self.pascal_name}RemoteDataSource;

  @GET('/{self.name}s')
  Future<List<{self.pascal_name}Model>> get{self.pascal_name}s();
}}
"""
        self._write(self.feature_path / "data/datasources" / f"{self.name}_remote_data_source.dart", ds_content)

        # Repository Implementation
        repo_impl_content = f"""
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/{self.name}.dart';
import '../../domain/repositories/{self.name}_repository.dart';
import '../datasources/{self.name}_remote_data_source.dart';
import '../../../../core/errors/failures.dart';

@LazySingleton(as: {self.pascal_name}Repository)
class {self.pascal_name}RepositoryImpl implements {self.pascal_name}Repository {{
  final {self.pascal_name}RemoteDataSource _remoteDataSource;

  {self.pascal_name}RepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<{self.pascal_name}>>> get{self.pascal_name}s() async {{
    try {{
      final models = await _remoteDataSource.get{self.pascal_name}s();
      return Right(models.map((e) => e.toEntity()).toList());
    }} catch (e) {{
      return Left(ServerFailure(message: e.toString()));
    }}
  }}

  @override
  Future<Either<Failure, {self.pascal_name}>> get{self.pascal_name}(String id) async {{
    // Implement detail fetch
    throw UnimplementedError();
  }}
}}
"""
        self._write(self.feature_path / "data/repositories" / f"{self.name}_repository_impl.dart", repo_impl_content)

    def generate_presentation(self):
        # Event
        event_content = f"""
part of '{self.name}_bloc.dart';

@freezed
class {self.pascal_name}Event with _${self.pascal_name}Event {{
  const factory {self.pascal_name}Event.started() = _Started;
  const factory {self.pascal_name}Event.refreshed() = _Refreshed;
}}
"""
        # State
        state_content = f"""
part of '{self.name}_bloc.dart';

@freezed
class {self.pascal_name}State with _${self.pascal_name}State {{
  const factory {self.pascal_name}State.initial() = _Initial;
  const factory {self.pascal_name}State.loading() = _Loading;
  const factory {self.pascal_name}State.success(List<{self.pascal_name}> {self.camel_name}s) = _Success;
  const factory {self.pascal_name}State.failure(String message) = _Failure;
}}
"""
        # Bloc
        bloc_content = f"""
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/{self.name}.dart';
import '../../domain/usecases/get_{self.name}s.dart';
import '../../../../core/usecases/usecase.dart';

part '{self.name}_event.dart';
part '{self.name}_state.dart';
part '{self.name}_bloc.freezed.dart';

@injectable
class {self.pascal_name}Bloc extends Bloc<{self.pascal_name}Event, {self.pascal_name}State> {{
  final Get{self.pascal_name}s _get{self.pascal_name}s;

  {self.pascal_name}Bloc(this._get{self.pascal_name}s) : super(const _Initial()) {{
    on<_Started>((event, emit) async {{
      emit(const _Loading());
      final result = await _get{self.pascal_name}s(const NoParams());
      result.fold(
        (l) => emit(_Failure(l.message)),
        (r) => emit(_Success(r)),
      );
    }});
  }}
}}
"""
        bloc_dir = self.feature_path / "presentation/bloc"
        self._write(bloc_dir / f"{self.name}_bloc.dart", bloc_content)
        # Event and State need separate files but are parts
        # Trick: Write them as separate files that match the part directives
        self._write(bloc_dir / f"{self.name}_event.dart", event_content)
        self._write(bloc_dir / f"{self.name}_state.dart", state_content)

        # Page
        page_content = f"""
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/{self.name}_bloc.dart';

class {self.pascal_name}Page extends StatelessWidget {{
  const {self.pascal_name}Page({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return BlocProvider(
      create: (context) => getIt<{self.pascal_name}Bloc>()..add(const {self.pascal_name}Event.started()),
      child: const {self.pascal_name}View(),
    );
  }}
}}

class {self.pascal_name}View extends StatelessWidget {{
  const {self.pascal_name}View({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(title: const Text('{self.pascal_name}')),
      body: BlocBuilder<{self.pascal_name}Bloc, {self.pascal_name}State>(
        builder: (context, state) {{
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            success: (items) => ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(items[index].name),
              ),
            ),
            failure: (msg) => Center(child: Text('Error: $msg')),
          );
        }},
      ),
    );
  }}
}}
"""
        self._write(self.feature_path / "presentation/pages" / f"{self.name}_page.dart", page_content)

    def run(self):
        self.create_structure()
        self.generate_domain()
        self.generate_data()
        self.generate_presentation()
        print("\n✨ Feature generation complete! Don't forget to run:")
        print("flutter pub run build_runner build --delete-conflicting-outputs")

def main():
    parser = argparse.ArgumentParser(description="Create a full Clean Architecture feature")
    parser.add_argument("--name", required=True, help="Feature name (e.g. user_profile)")
    args = parser.parse_args()

    FeatureGenerator(args.name).run()

if __name__ == "__main__":
    main()
