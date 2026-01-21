# Complete Audit Remediation Plan (Revised)

**Goal:** Fix ALL 10 issues + complete ALL missing features identified in audit.
**Scope:** Full remediation - no placeholders, production-ready fixes.

---

## Execution Order (Optimized)

### Sprint 1: Critical + Foundation (Issues #1, #2, #10)
1. **Save onboarding state** → `StorageService.setOnboardingCompleted(true)`
2. **IAP verification** → Add warning log + local premium flag (no backend = skip server verification with disclaimer)
3. **Rate App button** → Wire `url_launcher` to store URLs

### Sprint 2: Share System (Issue #3)
4. **NextPrayerCard Share** → `share_plus` with prayer time text
5. **SurahReader Share Surah** → Share surah name + selected verses
6. **SurahReader Share Verse** → Share individual verse with translation

### Sprint 3: Audio System (Issues #4, #6)
7. **Wire QuranAudioService** → Use Quran.com API for recitation
8. **Wire AudioService to Duas** → Use existing service for dua audio
9. **Wire AudioService to Names** → Play 99 Names audio

### Sprint 4: Favorites & Persistence (Issues #5, #8)
10. **Dua Favorites** → `StorageService.toggleFavorite()`
11. **Quran Settings Persistence** → Save font size, translation code

### Sprint 5: Navigation & Cleanup (Issues #7, #9)
12. **Notification deep-links** → `GoRouter.go()` based on payload
13. **Home notification icon** → Navigate to settings
14. **Delete dead code** → `city_search_screen.dart`, unused services

---

## Proposed Changes

### Sprint 1

#### [MODIFY] [onboarding_screen.dart](file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/onboarding/presentation/screens/onboarding_screen.dart)
- Save `onboardingCompleted = true` in `_completeOnboarding()`

#### [MODIFY] [purchase_service.dart](file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/core/services/purchase_service.dart)
- Add production disclaimer, save premium to `StorageService`

#### [MODIFY] [settings_screen.dart](file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/settings/presentation/screens/settings_screen.dart)
- Wire Rate App to `launchUrl(storeUrl)`

---

### Sprint 2

#### [MODIFY] [next_prayer_card.dart](file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/home/presentation/widgets/next_prayer_card.dart)
- Implement `Share.share()` for prayer time

#### [MODIFY] [surah_reader_screen.dart](file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/quran/presentation/screens/surah_reader_screen.dart)
- Implement `_shareSurah()` and `_shareVerse()`

---

### Sprint 3

#### [MODIFY] [surah_reader_screen.dart](file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/quran/presentation/screens/surah_reader_screen.dart)
- Wire `_playVerse()` to `QuranAudioService`

#### [MODIFY] [duas_screen.dart](file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/learning/presentation/screens/duas_screen.dart)
- Wire play button to `AudioService`

#### [MODIFY] [names_screen.dart](file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/learning/presentation/screens/names_screen.dart)
- Wire "Play All" button

---

### Sprint 4

#### [MODIFY] [duas_screen.dart](file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/learning/presentation/screens/duas_screen.dart)
- Wire favorites toggle

#### [MODIFY] [quran_settings_screen.dart](file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/settings/presentation/screens/quran_settings_screen.dart)
- Persist settings to `StorageService`

---

### Sprint 5

#### [MODIFY] [notification_service.dart](file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/core/services/notification_service.dart)
- Implement deep-link navigation

#### [MODIFY] [home_screen.dart](file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/home/presentation/screens/home_screen.dart)
- Wire notification icon to settings

#### [DELETE] [city_search_screen.dart](file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/settings/presentation/screens/city_search_screen.dart)
- Deprecated, replaced by `LocationSelectionScreen`

---

## Verification Plan

- `flutter build apk` after each sprint
- Hot reload test for UI changes
- Manual verification of each fixed feature

