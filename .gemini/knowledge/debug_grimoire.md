# 🐞 Debugger Grimoire (Troubleshooting & Fixes)

> **Owner:** Debugger (The Exterminator)
> **Purpose:** Repository of solved bugs, error patterns, and forensic techniques.

## 🩸 Common Error Patterns

### 1. "RenderFlex overflowed by..."
*   **Cause:** Unsound layout constraints (e.g., Column inside Column without Expanded).
*   **Fix:** Wrap the unbounded child in `Expanded` or `Flexible`.

### 2. "Setstate() called after dispose()"
*   **Cause:** An async operation (HTTP call) finishing after the user left the screen.
*   **Fix:** `if (mounted) setState(() {...});`

### 3. "Gradle build failed" (Android)
*   **Cause:** Version conflict (Kotlin version vs Gradle plugin version).
*   **Fix:** Check `android/build.gradle` and `android/gradle/wrapper/gradle-wrapper.properties`. Match versions using the Matrix.

## 🔍 Forensic Tools
*   **`flutter doctor -v`**: The MRI scan.
*   **`adb logcat | grep 'Caused by'`**: The Sniper approach.
*   **DevTools Memory Tab**: Essential for finding Leaks (Snapshot 1 vs Snapshot 2).
