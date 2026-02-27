---
name: flutter-visual-architecture
description: Mastering Impeller shaders (FLSL), Material 3 Dynamic Theming, and Responsive Layout Systems.
---

# ✨ Flutter Visual Architecture

## 🌈 FLSL (Flutter Shading Language)
Unlock GPU power for 2025 UI effects.
- **Effects:** Mesh gradients, real-time blur, animated noise, glowing edges.
- **Usage:** Write `.frag` files and load via `FragmentProgram`.
- **Optimization:** Reuse shader instances to avoid overhead.

## 🎨 Material 3 Dynamic Theming
- **Dynamic Color:** Support Android 12+ and iOS platform-level themes.
- **ColorScheme.fromImage:** Generate themed palettes from user-uploaded images/avatars.
- **Harmonization:** Ensure custom colors are harmonized with the dynamic primary color.

## 📱 Responsive Mastery
- **LayoutBuilder:** Design once, adapt everywhere (Mobile, Tablet, Desktop).
- **NavigationRail vs BottomNavBar:** Automatic switching based on screen width.
- **Design Tokens:** Use a centralized `AppTheme` class for all paddings, radii, and fonts.

## 🚀 Aesthetic "Wow" Checklist
- [ ] Glassmorphism (BackdropFilter)
- [ ] Shimmer loading states
- [ ] Smooth hero transitions
- [ ] Micro-animations for feedback
