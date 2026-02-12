# Flutter Package Compatibility Reference
# For Dart 3.5.0 / Flutter 3.24.0

## Critical: Packages Requiring Downgrade

| Package | Latest | Compatible | Notes |
|---------|--------|------------|-------|
| google_mobile_ads | 7.0.0 | 5.0.0 | Requires Dart >=3.9.0 |
| google_fonts | 8.0.1 | 6.0.0 | Requires Dart >=3.9.0 |
| flutter_local_notifications | 20.0.0 | 18.0.0 | Requires Dart >=3.6.0 |
| app_links | 7.0.0 | 6.4.1 | Requires Dart >=3.10.0 |
| flutter_lints | 6.0.0 | 5.0.0 | Requires Dart >=3.6.0 |
| workmanager | 0.9.0 | 0.7.0 | Requires Flutter >=3.32.0 |
| home_widget | 0.9.0 | 0.7.0 | Requires Flutter >=3.32.0 |
| flutter_svg | 2.2.3 | 2.0.17 | Requires Dart >=3.8.0 |
| image_picker | 1.1.2 | 1.0.7 | Requires Dart >=3.6.0 |
| awesome_notifications | 0.10.1 | 0.10.0 | intl conflict |

## Safe: Packages Already Compatible with Dart 3.5.0

| Package | Version | Min Dart |
|---------|---------|----------|
| sensors_plus | 7.0.0 | >=3.3.0 |
| permission_handler | 12.0.1 | ^3.5.0 |
| flutter_foreground_task | 9.2.0 | ^3.4.0 |
| android_alarm_manager_plus | 5.0.0 | >=3.1.0 |
| in_app_purchase | 3.1.11 | ^3.5.0 |
| in_app_review | 2.0.9 | >=2.12.0 |
| tutorial_coach_mark | 1.2.11 | >=2.12.0 |

## Special Cases

### intl Version Conflict
```
flutter_localizations pins intl to 0.19.0
awesome_notifications 0.10.1 requires intl ^0.20.0
```
**Solution:** Use awesome_notifications ^0.10.0

### SDK Version Check
```bash
# Check your Dart version
dart --version

# Check package requirements
flutter pub deps --style=compact | grep [package_name]
```

## Future Upgrade Path
When upgrading to Flutter 3.32+:
1. Update pubspec.yaml to latest versions
2. Run flutter pub upgrade
3. Test build
4. Address any breaking changes
