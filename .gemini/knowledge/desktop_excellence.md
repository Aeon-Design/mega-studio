# Desktop Excellence Grimoire 🖥️

> **Domain:** Native Desktop Development (Windows, macOS, Linux)
> **Goal:** 100% Native-feel across all desktop ecosystems.

## 🏁 Window Management
- **Size Constraints:** Always set `minimumSize` to prevent UI breakage.
- **Positioning:** Remember last window position/state in local storage.
- **Frameless Windows:** Use only for specialized splash screens or utility tools.

## 🖱️ Interaction Paradigms
- **Hover Effects:** Mandatory for all interactive elements.
- **Context Menus:** Right-click support on all lists, cards, and text inputs.
- **Tooltips:** Show on hover for all icon-only buttons.

## ⌨️ Keyboard Mastery
- **Shortcuts:** Implement common OS shortcuts (Ctrl/Cmd + S, Z, F).
- **Tab Order:** Logical tab navigation for all forms.
- **Enter/Escape:** Enter for primary action, Escape for cancel/close.

## 📂 System Integration
- **File System:** Use native file pickers (`file_picker`).
- **Tray Icons:** Use for background-running utility apps.
- **Notifications:** Use native OS notification systems.

## 🚀 Performance
- **Resizable Layouts:** Use `LayoutBuilder` to adapt to any window size.
- **Hardware Acceleration:** Ensure Skia/Impeller is optimized for desktop GPUs.
