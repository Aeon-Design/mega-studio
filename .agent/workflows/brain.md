---
description: Brain - Proje hafızasını yönet (init, show, add decisions/errors/completed)
---

// turbo-all

1. Brain'i başlat (yeni proje için):
   ```bash
   python C:\Users\Abdullah\.agent\skills\brain.py --project . --init
   ```

2. Brain'i göster:
   ```bash
   python C:\Users\Abdullah\.agent\skills\brain.py --project . --show
   ```

3. Kullanıcı ne istiyorsa yap:
   - Karar ekle: `--add-decision "..."`
   - Hata ekle: `--add-error "..."`
   - Tamamlanan iş ekle: `--add-completed "..."`
   - Hedef ekle: `--add-goal "..."`
