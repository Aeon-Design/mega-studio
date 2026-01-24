---
description: Feature - Yeni Clean Architecture feature oluştur
---

// turbo-all

1. Feature oluştur:
   ```bash
   python C:\Users\Abdullah\.agent\skills\clean-architecture\scripts\create_feature.py --name <FEATURE_NAME> --output .
   ```

2. Code generation çalıştır:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. Brain'e kaydet:
   ```bash
   python C:\Users\Abdullah\.agent\skills\brain.py --add-completed "Created feature: <FEATURE_NAME>"
   ```

Not: <FEATURE_NAME> yerine kullanıcının istediği feature adını koy.
