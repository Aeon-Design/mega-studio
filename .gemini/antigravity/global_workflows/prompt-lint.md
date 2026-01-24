---
description: Prompt Linter - Ajan promptlarinin PTCF uyumlulugunu kontrol et
---

// turbo-all

1. Tum ajanlari lint et:
   ```bash
   python C:\Users\Abdullah\.agent\skills\prompt_linter.py --all
   ```

2. Tek dosya kontrol:
   ```bash
   python C:\Users\Abdullah\.agent\skills\prompt_linter.py --file <agent.md>
   ```

3. Duzeltme onerisi:
   ```bash
   python C:\Users\Abdullah\.agent\skills\prompt_linter.py --fix --file <agent.md>
   ```

Not: PTCF = Persona, Task, Context, Format
