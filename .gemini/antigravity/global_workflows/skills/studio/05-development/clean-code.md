---
description: Mandatory coding standards. Naming conventions, formatting, and simplicity.
---

# Clean Code Skill 🧹

> **"Clean code always looks like it was written by someone who cares."**

## 🎯 Purpose
This skill is mandatory for **ALL** agents.
Every line of code written in this studio must pass the Clean Code check.

---

## 🧠 Cognitive Complexity
Code is read 10x more than it is written.
*   **Max Limit:** 15 (SonarQube Scale).
*   **Nesting:** Avoid `if` inside `for` inside `if`. Return early.
*   **Boolean Blindness:** Don't use `flag` arguments (`process(true)`). Use `process(isAdmin: true)`.

### 📝 Formatting & Style
*   **Dart:** `dart format .` is law. 80 chars line length.
*   **Trailing Commas:** ALWAYS use them in parameters. It makes git diffs cleaner.

## 📏 Golden Rules

### 1. Naming is Everything
-   **Variables:** `noun` (e.g., `user`, `accountBalance`).
-   **Functions:** `verb` (e.g., `getUser`, `calculateBalance`).
-   **Booleans:** `is`, `has`, `can` (e.g., `isValid`, `hasPermission`).
-   **Classes:** `PascalCase` (e.g., `UserProfile`).
-   **Constants:** `SCREAMING_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`).

### 2. Functions Should be Small
-   A function should do **one thing**.
-   If it's > 20 lines, pause. Can you extract a sub-task?
-   Avoid > 3 arguments. Use a configuration object instead.

### 3. Comments
-   **Don't** comment on *what* the code does. The code should say that.
-   **Do** comment on *why* the code does it (if it's weird).
-   ✅ `// Using a set here for O(1) lookup performance`
-   ❌ `// Sets the user id` -> `userId = 1`

---

## 🧪 "Boy Scout Rule"
> **"Always leave the campground cleaner than you found it."**
If you touch a file to fix a bug, and you see a typo or bad formatting nearby, **fix it**.

---

## 🚫 Forbidden Practices
1.  **Magic Numbers:** `if (status == 2)` -> what is 2? Use `enum Status`.
2.  **Duplication (DRY):** If you copy-paste code, you have failed. Extract a function.
3.  **Zombie Code:** Commented out code? Delete it. Git has history.
