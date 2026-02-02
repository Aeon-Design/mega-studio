---
name: "Storage & Sync"
version: "1.0.0"
description: |
  Flutter persistence patterns: Hive, Drift, SharedPreferences, cloud sync.
  Adapted from SwiftData/CoreData patterns.
  Tetikleyiciler: "database", "storage", "hive", "drift", "sync", "offline", "migration"
---

# Flutter Storage & Sync

## Amaç
Yerel depolama ve cloud sync best practices.

---

## Paket Seçimi

| İhtiyaç | Paket | Performans |
|---------|-------|-----------|
| Key-Value | SharedPreferences | ⭐⭐⭐ |
| NoSQL (Fast) | Hive | ⭐⭐⭐⭐⭐ |
| NoSQL (Typed) | Isar | ⭐⭐⭐⭐⭐ |
| SQL (Simple) | sqflite | ⭐⭐⭐ |
| SQL (Type-safe) | Drift | ⭐⭐⭐⭐ |
| Encrypted | flutter_secure_storage | ⭐⭐⭐ |

---

## Hive Setup

### pubspec.yaml
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

### Initialization
```dart
await Hive.initFlutter();
Hive.registerAdapter(UserAdapter());
final box = await Hive.openBox<User>('users');
```

### Model
```dart
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String id;
  
  @HiveField(1)
  late String name;
  
  @HiveField(2)
  late DateTime createdAt;
}
```

---

## Drift Setup (SQL)

### pubspec.yaml
```yaml
dependencies:
  drift: ^2.14.1
  sqlite3_flutter_libs: ^0.5.18
  path_provider: ^2.1.1
  path: ^1.8.3

dev_dependencies:
  drift_dev: ^2.14.1
  build_runner: ^2.4.8
```

### Database Definition
```dart
import 'package:drift/drift.dart';

part 'database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);
  
  @override
  int get schemaVersion => 1;
}
```

---

## Migration Strategy

### Hive Migration
```dart
// Version tracking
final versionBox = await Hive.openBox('version');
final currentVersion = versionBox.get('db_version', defaultValue: 0);

if (currentVersion < 1) {
  await migrateToV1();
  await versionBox.put('db_version', 1);
}
```

### Drift Migration
```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async {
    await m.createAll();
  },
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      await m.addColumn(users, users.email);
    }
    if (from < 3) {
      await m.createTable(posts);
    }
  },
);
```

---

## Repository Pattern

```dart
abstract class UserRepository {
  Future<User?> getById(String id);
  Future<List<User>> getAll();
  Future<void> save(User user);
  Future<void> delete(String id);
  Stream<List<User>> watch();
}

class HiveUserRepository implements UserRepository {
  final Box<User> _box;
  
  HiveUserRepository(this._box);
  
  @override
  Future<User?> getById(String id) async => _box.get(id);
  
  @override
  Future<List<User>> getAll() async => _box.values.toList();
  
  @override
  Future<void> save(User user) async => await _box.put(user.id, user);
  
  @override
  Future<void> delete(String id) async => await _box.delete(id);
  
  @override
  Stream<List<User>> watch() => _box.watch().map((_) => _box.values.toList());
}
```

---

## Offline-First Pattern

```dart
class OfflineFirstRepository<T> {
  final LocalRepository<T> _local;
  final RemoteRepository<T> _remote;
  final ConnectivityService _connectivity;
  
  Future<List<T>> getAll() async {
    // Always return local first
    final localData = await _local.getAll();
    
    // Sync in background if online
    if (await _connectivity.isOnline) {
      _syncFromRemote();
    }
    
    return localData;
  }
  
  Future<void> save(T item) async {
    // Save locally first
    await _local.save(item);
    
    // Queue for remote sync
    await _syncQueue.add(item);
    
    // Try immediate sync
    if (await _connectivity.isOnline) {
      await _processSyncQueue();
    }
  }
  
  Future<void> _syncFromRemote() async {
    final remoteData = await _remote.getAll();
    for (final item in remoteData) {
      await _local.save(item);
    }
  }
}
```

---

## Cloud Sync Patterns

### Firebase Firestore
```dart
class FirestoreSyncService {
  final FirebaseFirestore _firestore;
  final Box _localBox;
  
  Stream<void> syncCollection(String collection) {
    return _firestore.collection(collection).snapshots().map((snapshot) {
      for (final doc in snapshot.docs) {
        _localBox.put(doc.id, doc.data());
      }
    });
  }
  
  Future<void> pushLocal(String collection) async {
    final batch = _firestore.batch();
    for (final key in _localBox.keys) {
      final ref = _firestore.collection(collection).doc(key);
      batch.set(ref, _localBox.get(key));
    }
    await batch.commit();
  }
}
```

---

## Secure Storage

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

---

## Checklist

- [ ] Appropriate storage solution selected
- [ ] Repository pattern implemented
- [ ] Migration strategy defined
- [ ] Offline-first if needed
- [ ] Secure storage for sensitive data
- [ ] Sync conflict resolution planned
