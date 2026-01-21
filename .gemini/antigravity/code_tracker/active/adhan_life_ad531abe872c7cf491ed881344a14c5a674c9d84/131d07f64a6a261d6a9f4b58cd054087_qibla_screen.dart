Ânimport 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/qibla_service.dart';
import '../../../../core/services/location_service.dart';

/// Qibla Screen - Compass showing Qibla direction
class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double? _qiblaDirection;
  double? _distance;
  String? _locationName;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppTokens.animNormal,
    );
    _loadQiblaData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadQiblaData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final qiblaService = ref.read(qiblaServiceProvider);

      final position = await locationService.getCurrentPosition();
      final direction = qiblaService.calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );
      final distance = qiblaService.calculateDistanceToKaaba(
        position.latitude,
        position.longitude,
      );
      final city = await locationService.getCityFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _qiblaDirection = direction;
        _distance = distance;
        _locationName = city;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final compassAsync = ref.watch(compassStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGradient : null,
          color: isDark ? null : Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(context),

              // Main Content
              Expanded(
                child: _isLoading
                    ? _buildLoading()
                    : _error != null
                        ? _buildError()
                        : compassAsync.when(
                            data: (event) => _buildCompass(event?.heading, isDark),
                            loading: () => _buildLoading(),
                            error: (e, _) => _buildCompassFallback(isDark),
                          ),
              ),

              // Bottom Info
              _buildBottomInfo(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // Duplicate methods removed


  Widget _buildCompass(double? heading, bool isDark) {
    final qiblaAngle = _qiblaDirection ?? 0;
    final rotation = heading != null ? (qiblaAngle - heading) * (pi / 180) : 0.0;
    final textColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Location
          if (_locationName != null)
            Text(
              _locationName!,
              style: AppTypography.titleMedium.copyWith(
                color: textColor,
              ),
            ),
          const SizedBox(height: AppTokens.spacing8),

          // Direction degrees with Kaaba icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${qiblaAngle.toStringAsFixed(1)}¬∞',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mosque,
                  color: AppColors.gold,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spacing32),

          // Compass
          SizedBox(
            width: AppTokens.qiblaCompassSize,
            height: AppTokens.qiblaCompassSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),

                // Compass markings
                CustomPaint(
                  size: Size(
                    AppTokens.qiblaCompassSize - 20,
                    AppTokens.qiblaCompassSize - 20,
                  ),
                  painter: _CompassMarkingsPainter(
                    color: isDark ? Colors.white : AppColors.textSecondary
                  ),
                ),

                // Rotating needle
                Transform.rotate(
                  angle: rotation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Kaaba icon
                      Container(
                        padding: const EdgeInsets.all(AppTokens.spacing12),
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mosque,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      // Needle
                      Container(
                        width: 4,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.gold,
                              AppColors.gold.withValues(alpha: 0.2),
                            ],
                          ),
                          borderRadius: AppTokens.borderRadiusFull,
                        ),
                      ),
                    ],
                  ),
                ),

                // Center dot
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTokens.spacing32),

          // Accuracy indicator
          _buildAccuracyIndicator(heading),
        ],
      ),
    );
  }

  Widget _buildCompassFallback(bool isDark) {
    return _buildCompass(null, isDark);
  }

  Widget _buildAccuracyIndicator(double? heading) {
    final isCalibrated = heading != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isCalibrated ? Icons.check_circle : Icons.warning,
          color: isCalibrated ? AppColors.success : AppColors.warning,
          size: AppTokens.iconSmall,
        ),
        const SizedBox(width: AppTokens.spacing8),
        Text(
          isCalibrated ? 'Compass calibrated' : 'Move device to calibrate',
          style: TextStyle(
            color: isCalibrated ? AppColors.success : AppColors.warning,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
       leading: BackButton(
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
      title: Text(
        'Qibla Direction',
        style: AppTypography.titleMedium.copyWith(
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.gold),
    );
  }

  Widget _buildError() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppTokens.spacing16),
            Text(
              _error ?? 'Something went wrong',
              style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.spacing24),
            ElevatedButton.icon(
              onPressed: _loadQiblaData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }


  
  Widget _buildBottomInfo(bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDark ? Colors.white54 : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(AppTokens.spacing24),
      child: Column(
        children: [
          // Distance to Kaaba
          if (_distance != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.place,
                  color: AppColors.gold,
                  size: AppTokens.iconSmall,
                ),
                const SizedBox(width: AppTokens.spacing8),
                Text(
                  '${_distance!.toStringAsFixed(0)} km to Makkah',
                  style: AppTypography.titleMedium.copyWith(
                    color: textColor,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppTokens.spacing16),

          // Instructions
          Text(
            'Point your phone towards the Kaaba icon\nto face the Qibla direction',
            style: AppTypography.bodySmall.copyWith(
              color: secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Custom painter for compass markings
class _CompassMarkingsPainter extends CustomPainter {
  final Color color;

  _CompassMarkingsPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.24)
      ..strokeWidth = 1;

    // Draw degree markings
    for (var i = 0; i < 360; i += 15) {
      final angle = i * pi / 180 - pi / 2;
      final isCardinal = i % 90 == 0;
      final length = isCardinal ? 15.0 : 8.0;

      final start = Offset(
        center.dx + (radius - length) * cos(angle),
        center.dy + (radius - length) * sin(angle),
      );
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      paint.color = isCardinal ? color.withValues(alpha: 0.54) : color.withValues(alpha: 0.24);
      paint.strokeWidth = isCardinal ? 2 : 1;
      canvas.drawLine(start, end, paint);
    }

    // Draw cardinal direction labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final directions = ['N', 'E', 'S', 'W'];
    for (var i = 0; i < 4; i++) {
      final angle = i * 90 * pi / 180 - pi / 2;
      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: color.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      final offset = Offset(
        center.dx + (radius - 30) * cos(angle) - textPainter.width / 2,
        center.dy + (radius - 30) * sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant _CompassMarkingsPainter oldDelegate) => oldDelegate.color != color;
}
Ä Äã
ã≤ ≤Ω
Ω√ √≈*cascade08
≈∆ ∆«*cascade08
«   Ã*cascade08
ÃÕ Õ–
–— —”*cascade08
”‰ ‰
Ò Ò˚
˚¸ ¸É
ÉÑ ÑÖ*cascade08
ÖÜ Üä*cascade08
äå åí
íì ì•
•¥ ¥∑*cascade08
∑“ “ﬁ
ﬁﬂ ﬂ·*cascade08
·‚ ‚Á
ÁË ËÈ*cascade08
ÈÍ ÍÎ*cascade08
ÎÙ Ùı
ıˆ ˆ¸
¸ö ö¶
¶® ®´
´¨ ¨≠*cascade08
≠Æ Æ±
±≤ ≤µ*cascade08
µ∑ ∑∏*cascade08
∏§ §©*cascade08
©è èì*cascade08
ìî îñ
ñò òô*cascade08
ôö öõ*cascade08
õú úû
ûü ü†*cascade08
†° °¢*cascade08
¢£ £§*cascade08
§ê ê’*cascade08
’ˆ ˆ˘
˘˚ ˚ê
êí íó*cascade08
óô ôõ *cascade08
õú úû*cascade08
ûü ü°*cascade08
°¢ ¢§*cascade08
§• •≥*cascade08
≥µ µ∂*cascade08
∂∑ 
∑º º≈*cascade08
≈… 
…Œ Œ∞
∞≥ ≥µ*cascade08
µª ªÀ*cascade08
ÀŸ Ÿ⁄*cascade08
⁄‚ ‚„*cascade08
„Û Ûı*cascade08
ıô ôö*cascade08
öù ù†*cascade08
†§ §¶*cascade08
¶¥ ¥¡
¡⁄ ⁄‹*cascade08
‹ﬂ ﬂ‡*cascade08
‡· ·Ë
ËÈ ÈÎ*cascade08
Î˘ ˘˛
˛ˇ ˇÄ*cascade08
ÄÅ ÅÇ*cascade08
Çö öõ*cascade08
õù ùû
ûü ü¢
¢£ £ß*cascade08
ß∑ ∑¬
¬≈ ≈∆
∆« «Ã
ÃÕ ÕŒ*cascade08
Œ‰ ‰Â*cascade08
ÂÊ ÊÏ
ÏÌ ÌÔ
Ô ˆ
ˆé éè
èñ ñò
òö öõ*cascade08
õú úù*cascade08
ù≥ ≥∑*cascade08
∑ª ªø
ø¿ ¿ƒ
ƒ≈ ≈«*cascade08
«   À*cascade08
À· ·Ï
Ï ı
ı˙ ˙˝
˝˛ ˛Ñ
ÑÖ Öá*cascade08
áâ âå
åç çé
éè èññû*cascade08
ûæ æ∆
∆« «…
…   Ã
ÃÕ Õ⁄
⁄€ €›*cascade08
›˚ ˚Å
ÅÇ ÇÖ
ÖÜ Üà
àâ âã
ãå åê
êë ëì
ìî îó
óò òú
úù ù°
°¢ ¢®*cascade08®™*cascade08
™∆ ∆ *cascade08
 ÿ ÿŸ*cascade08
Ÿ‹ ‹ﬁ*cascade08
ﬁÏ ÏÓ*cascade08
ÓÔ Ô*cascade08
Û Ûı
ıˆ ˆ˘
˘ä äé
éè èí*cascade08
íî îó
óò 
òõ õ°*cascade08
°¢ 
¢± ±≤*cascade08
≤ø ø√*cascade08
√’ ’Ÿ*cascade08
Ÿ› ›·
·„ „Ë*cascade08
ËÍ ÍÏ*cascade08
ÏÌ 
ÌÓ 
ÓÔ 
ÔÒ ÒÚ *cascade08ÚÛ*cascade08
ÛÙ Ùı*cascade08
ıˆ 
ˆ˚ ˚¸ *cascade08
¸˝ 
˝˛ 
˛Ä 
ÄÅ ÅÇ*cascade08
Ç¢ ¢≤ *cascade08≤ø*cascade08ø≈ *cascade08≈è*cascade08è∆ *cascade08∆ *cascade08 è, *cascade08è,ê,*cascade08ê,ë, *cascade08ë,ï,*cascade08ï,ñ, *cascade08ñ,ù,*cascade08ù,†/ *cascade08†/Ä0*cascade08Ä0ö: *cascade08ö:õ:*cascade08õ:ú: *cascade08ú:†:*cascade08†:°: *cascade08°:®:*cascade08®:†A *cascade08†A´A*cascade08´AÕA *cascade08ÕA’A*cascade08’A¶G *cascade08¶G≥G*cascade08≥G¿G *cascade08¿G√G*cascade08√GƒG *cascade08ƒGÕG*cascade08ÕGŒG *cascade08ŒGœG*cascade08œG–G *cascade08–G“G*cascade08“G”G *cascade08”G’G*cascade08’G÷G *cascade08÷GˆG*cascade08ˆG˜G *cascade08˜GóL*cascade08óLôL *cascade08ôLÁL*cascade08ÁLËL *cascade08ËL¸L*cascade08¸L˝L *cascade08˝L˛L*cascade08˛LˇL *cascade08ˇLÏT *cascade08ÏTÒT *cascade08ÒTåV*cascade08åVÕ[ *cascade08Õ[—[*cascade08—[´^ *cascade08´^∏^*cascade08∏^í` *cascade08í`Â`*cascade08Â`¶b *cascade08¶bßb*cascade08ßbØb *cascade08Øb¥b*cascade08¥bµb *cascade08µb¿b*cascade08¿b¬b *cascade08¬b√b*cascade08√bÿf *cascade08ÿfŸf*cascade08Ÿf·f *cascade08·fÊf*cascade08ÊfÁf *cascade08ÁfÚf*cascade08ÚfÙf *cascade08Ùfıf*cascade08ıf¯f *cascade08¯f˘f*cascade08˘fÅg *cascade08ÅgÜg*cascade08Ügág *cascade08ágíg*cascade08ígîg *cascade08îgïg*cascade08ïgÎj *cascade08ÎjÏj*cascade08ÏjÙj *cascade08Ùj˘j*cascade08˘j˙j *cascade08˙jÉk*cascade08ÉkÑk *cascade08Ñkák*cascade08ák˛m *cascade08
˛mùn ùnûn*cascade08
ûn°n °n≠n*cascade08
≠n≈n ≈nÕn*cascade08
ÕnŒn Œn”n*cascade08
”n‘n ‘nﬂn*cascade08
ﬂnÂn "(ad531abe872c7cf491ed881344a14c5a674c9d842qfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/features/qibla/presentation/screens/qibla_screen.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life