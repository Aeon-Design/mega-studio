---
description: Ralph Wiggum - Otonom QA döngüsü (test, lint, build verification)
---

// turbo-all

1. Ralph QA sistemini çalıştır:
   ```bash
   python C:\Users\Abdullah\.agent\skills\ralph.py --project . --iterations 3
   ```

2. Sonuçları değerlendir:
   - ✅ Build passes
   - ✅ Tests pass  
   - ✅ Lint clean
   - ✅ Format correct

3. Hata varsa düzelt ve tekrar ralph çalıştır.

4. Brain'e kaydet:
   ```bash
   python C:\Users\Abdullah\.agent\skills\brain.py --add-completed "QA passed - all checks green"
   ```
