---
name: flutter-production-scale
description: Scaling Flutter development using Monorepos, Melos, and Feature-First Architecture.
---

# 🏗️ Flutter Production Scale

## 📦 Monorepo Strategy
Stop creating separate repos for every package. Use a Monorepo.

### Structure
```
/
  melos.yaml
  apps/
    customer_app/
    admin_panel/
  packages/
    ui_kit/        <-- Shared Widgets
    core/          <-- Networking, Logging
    features/      <-- Feature implementations
      auth/
      cart/
```

### Melos
The standard tool for Flutter Monorepos.
- **Bootstrap:** `melos bootstrap` links strictly defined local packages.
- **Scripts:** Define `test`, `lint`, `build_runner` scripts in `melos.yaml` to run across all packages instantly.

## 🧩 Feature-First Architecture
Do not organize by Layer (pages, providers, repos). Organize by **Feature**.
- `features/auth/`
    - `presentation/`
    - `data/`
    - `domain/`
- **Rule:** A feature should not import another feature directly. Use a shared `core` or Interfaces if needed.

## 🏭 CI/CD for Monorepos
- **Selective Build:** Only build/test the apps/packages that changed (`melos list --diff`).
