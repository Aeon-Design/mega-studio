Ã6import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adhan_life/core/theme/app_colors.dart';
import 'package:adhan_life/core/theme/app_tokens.dart';
import 'package:adhan_life/core/theme/app_typography.dart';
import 'package:adhan_life/l10n/app_localizations.dart';

class ZikrCounterWidget extends StatefulWidget {
  const ZikrCounterWidget({super.key});

  @override
  State<ZikrCounterWidget> createState() => _ZikrCounterWidgetState();
}

class _ZikrCounterWidgetState extends State<ZikrCounterWidget> {
  int _count = 0;
  final List<({int count, DateTime time})> _history = [];

  void _increment() {
    HapticFeedback.lightImpact();
    setState(() {
      _count++;
    });
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _count = 0;
    });
  }

  void _save() {
    if (_count == 0) return;
    HapticFeedback.selectionClick();
    setState(() {
      _history.insert(0, (count: _count, time: DateTime.now()));
      if (_history.length > 3) _history.removeLast();
      _count = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved $_count zikr')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppTokens.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : Colors.white,
        borderRadius: AppTokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tasbih',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    color: isDark ? Colors.white70 : AppColors.primary,
                    tooltip: 'Save',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh_outlined),
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    tooltip: 'Reset',
                     padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spacing16),
          
          // Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppTokens.spacing16,
            ),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.background,
              borderRadius: AppTokens.borderRadiusMedium,
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.divider,
              ),
            ),
            child: Text(
              '$_count',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          
          const SizedBox(height: AppTokens.spacing16),

          // History - Last 3 records
          if (_history.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _history.take(3).map((record) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${record.count}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppTokens.spacing8),
          ],

          // Main Button
          SizedBox(
            width: 100,
            height: 100,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _increment,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 3,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.fingerprint,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.spacing8),
          Text(
            'Tap to Count',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
… …Ñ*cascade08
ÑÛ Ûë*cascade08
ëª ª¿*cascade08
¿¡ ¡¬*cascade08
¬√ √—*cascade08
—“ “’*cascade08
’÷ ÷‹*cascade08
‹ﬁ ﬁ‚*cascade08
‚„ „ì*cascade08
ìî îõ*cascade08
õù ù•*cascade08
•¶ ¶Æ*cascade08
ÆØ Ø∏*cascade08
∏∫ ∫√*cascade08
√ƒ ƒ *cascade08
 Ã ÃÕ*cascade08
Õœ œ›*cascade08
›Æ	 Æ	Ø	*cascade08
Ø	¥	 ¥	∂	*cascade08
∂	∑	 ∑	æ	*cascade08
æ	ø	 ø	¿	*cascade08
¿	è èê*cascade08
êë ëï*cascade08
ïñ ñù*cascade08
ùÕ ÕŒ*cascade08
Œœ œ”*cascade08
”‘ ‘€*cascade08
€¯ ¯˘*cascade08
˘˙ ˙˛*cascade08
˛ˇ ˇÜ*cascade08
Ü¬ ¬√*cascade08
√ƒ ƒ»*cascade08
»… …–*cascade08
–˝ ˝˛*cascade08
˛ˇ ˇÉ*cascade08
ÉÑ Ñã*cascade08
ãÛ ÛÛ*cascade08
Û€! €!Ê$*cascade08
Ê$Á$ Á$ˇ'*cascade08
ˇ'Ä( Ä(ñ)*cascade08
ñ)ö) ö)∑**cascade08
∑*¸* ¸*˝**cascade08
˝*ñ+ ñ+ó+*cascade08
ó+⁄, ⁄,€,*cascade08
€,ë/ ë/í/*cascade08
í/ì/ ì/ó/*cascade08
ó/ò/ ò/ü/*cascade08
ü/ç1 ç1é1*cascade08
é1è1 è1ì1*cascade08
ì1î1 î1õ1*cascade08
õ1ø1 ø1¿1*cascade08
¿1Ç3 Ç3É3*cascade08
É3Ã6 "(ad531abe872c7cf491ed881344a14c5a674c9d842wfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/home/presentation/widgets/zikr_counter_widget.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life