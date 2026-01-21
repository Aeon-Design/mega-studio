---
description: Best practices for Pine Script V5 algorithmic trading development.
---

# Pine Script V5 Standards 📈

## Core Rules
1.  **Repaint Protection:** Always use `barstate.isconfirmed` for entry signals.
2.  **Explicit Types:** Define variables with types (`float`, `int`).
3.  **Security:** specific `request.security` without repainting lookahead.
