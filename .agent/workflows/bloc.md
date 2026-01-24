---
description: Bloc - Yeni Bloc state management oluştur (event, state, test dahil)
---

// turbo-all

1. Bloc oluştur:
   ```bash
   python C:\Users\Abdullah\.agent\skills\state-management\scripts\create_bloc.py --name <BLOC_NAME> --feature <FEATURE_NAME>
   ```

2. Code generation çalıştır:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. Brain'e kaydet:
   ```bash
   python C:\Users\Abdullah\.agent\skills\brain.py --add-completed "Created Bloc: <BLOC_NAME>"
   ```

Not: <BLOC_NAME> ve <FEATURE_NAME> yerine kullanıcının istediği isimleri koy.
