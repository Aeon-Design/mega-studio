---
name: server-driven-ui
description: Patterns for implementing Server-Driven UI (SDUI) to decouple view logic from app binaries.
---

# 📡 Server-Driven UI (SDUI)

Decouple your UI from the App Store release cycle.

## 🧠 Core Concept
Returns a JSON/Protobuf representation of the UI tree from the backend. The client maps these "Tokens" to actual Flutter Widgets.

## 🛠️ Implementation Approaches

### 1. JSON-to-Widget (Custom)
Best for specific, controlled dynamic sections (e.g., Home Page).
- **Backend:** Sends JSON: `{ "type": "card", "children": [...] }`
- **Client:** `WidgetFactory` maps "card" -> `CardWidget()`.

### 2. Frameworks (Mirai / Duit)
Best for full-app SDUI.
- **Mirai:** Robust, standard-compliant SDUI framework.
- **Duit:** High performance, supports event handling and network actions.

## 🚀 Best Practices
1.  **Version Logic:** Always send an `app_version` header. The backend might need to fallback if the client doesn't support a new widget type.
2.  **Caching:** Cache SDUI responses aggressively but validate frequently.
3.  **Actions:** Define a protocol for actions (e.g., `action: "navigate", target: "/details/1"`).
