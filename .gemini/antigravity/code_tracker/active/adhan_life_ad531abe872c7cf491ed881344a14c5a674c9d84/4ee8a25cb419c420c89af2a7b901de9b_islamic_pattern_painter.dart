¶7import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter for Islamic geometric patterns
///
/// Draws traditional 8-pointed star pattern (Rub el Hizb) and
/// decorative geometric shapes inspired by Islamic architecture
class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final PatternType patternType;

  IslamicPatternPainter({
    required this.color,
    this.opacity = 0.1,
    this.patternType = PatternType.eightPointedStar,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    switch (patternType) {
      case PatternType.eightPointedStar:
        _drawEightPointedStar(canvas, size, paint);
        break;
      case PatternType.geometricGrid:
        _drawGeometricGrid(canvas, size, paint);
        break;
      case PatternType.cornerCircles:
        _drawCornerCircles(canvas, size, paint);
        break;
      case PatternType.crescentMoon:
        _drawCrescentMoon(canvas, size, paint);
        break;
    }
  }

  /// Draw 8-pointed Islamic star (Rub el Hizb)
  void _drawEightPointedStar(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.3;

    // Outer star points
    final outerPoints = <Offset>[];
    final innerPoints = <Offset>[];

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - math.pi / 2;

      // Outer point
      outerPoints.add(Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      ));

      // Inner point (between outer points)
      final innerAngle = angle + math.pi / 8;
      innerPoints.add(Offset(
        center.dx + (radius * 0.4) * math.cos(innerAngle),
        center.dy + (radius * 0.4) * math.sin(innerAngle),
      ));
    }

    // Draw star by connecting points
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final nextIndex = (i + 1) % 8;

      if (i == 0) {
        path.moveTo(outerPoints[i].dx, outerPoints[i].dy);
      }

      // Outer point -> Inner point -> Next outer point
      path.lineTo(outerPoints[i].dx, outerPoints[i].dy);
      path.lineTo(innerPoints[i].dx, innerPoints[i].dy);
      path.lineTo(outerPoints[nextIndex].dx, outerPoints[nextIndex].dy);
    }
    path.close();

    canvas.drawPath(path, paint);

    // Draw center circle
    canvas.drawCircle(center, radius * 0.15, paint);
  }

  /// Draw geometric grid pattern
  void _drawGeometricGrid(Canvas canvas, Size size, Paint paint) {
    const spacing = 40.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Diagonal crosses at intersections
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        const crossSize = 8.0;
        canvas.drawLine(
          Offset(x - crossSize, y - crossSize),
          Offset(x + crossSize, y + crossSize),
          paint,
        );
        canvas.drawLine(
          Offset(x + crossSize, y - crossSize),
          Offset(x - crossSize, y + crossSize),
          paint,
        );
      }
    }
  }

  /// Draw decorative circles in corners
  void _drawCornerCircles(Canvas canvas, Size size, Paint paint) {
    final radialPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset.zero,
        radius: 100,
      ))
      ..style = PaintingStyle.fill;

    final corners = [
      Offset(0, 0), // Top-left
      Offset(size.width, 0), // Top-right
      Offset(0, size.height), // Bottom-left
      Offset(size.width, size.height), // Bottom-right
    ];

    for (final corner in corners) {
      // Multiple concentric circles
      for (int i = 1; i <= 3; i++) {
        canvas.drawCircle(corner, 30.0 * i, paint);
      }

      // Radial gradient fill
      canvas.save();
      canvas.translate(corner.dx, corner.dy);
      canvas.drawCircle(Offset.zero, 80, radialPaint);
      canvas.restore();
    }
  }

  void _drawCrescentMoon(Canvas canvas, Size size, Paint paint) {
    // Draw a large crescent moon on the right side
    final center = Offset(size.width * 0.8, size.height * 0.4);
    final radius = size.width * 0.35;
    
    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    
    // Subtract inner circle to create crescent
    final innerCenter = Offset(center.dx - radius * 0.3, center.dy);
    final innerPath = Path();
    innerPath.addOval(Rect.fromCircle(center: innerCenter, radius: radius * 0.9));
    
    final crescentPath = Path.combine(
      PathOperation.difference,
      path,
      innerPath,
    );

    // Draw crescent
    // Use fill style for crescent
    final fillPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(crescentPath, fillPaint);
    
    // Draw some stars around with same fill paint
    _drawStar(canvas, Offset(size.width * 0.2, size.height * 0.2), 4, fillPaint);
    _drawStar(canvas, Offset(size.width * 0.4, size.height * 0.7), 3, fillPaint);
    _drawStar(canvas, Offset(size.width * 0.1, size.height * 0.6), 5, fillPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
     final path = Path();
     // Simple 4-point star
     path.moveTo(center.dx, center.dy - radius);
     path.quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy);
     path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius);
     path.quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy);
     path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius);
     path.close();
     canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.patternType != patternType;
  }
}

/// Pattern types for Islamic geometric designs
enum PatternType {
  /// 8-pointed star (Rub el Hizb)
  eightPointedStar,

  /// Grid with diagonal crosses
  geometricGrid,

  /// Decorative circles in corners
  cornerCircles,
  
  /// Crescent Moon and Stars
  crescentMoon,
}
¶7"(ad531abe872c7cf491ed881344a14c5a674c9d842cfile:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life/lib/core/theme/islamic_pattern_painter.dart:7file:///c:/Users/Abdullah/Projects/AdhanLife/adhan_life