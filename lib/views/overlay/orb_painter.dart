import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/jarvis_state.dart';
import '../../core/constants/app_theme.dart';

class OrbPainter extends CustomPainter {
  final double animationValue;
  final JarvisState state;

  OrbPainter({
    required this.animationValue,
    required this.state,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (state == JarvisState.gamingMode) {
      // In gaming mode, draw nothing or a static micro-dot to keep 0% GPU
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.6;

    // 1. Draw dynamic state effects behind the orb
    if (state == JarvisState.listening) {
      _drawListeningRipples(canvas, center, radius);
    } else if (state == JarvisState.thinking) {
      _drawThinkingHalo(canvas, center, radius);
    } else if (state == JarvisState.speaking) {
      _drawSpeakingHarmonics(canvas, center, radius);
    }

    // 2. Draw outer glowing stroke
    final strokePaint = Paint()
      ..color = AppTheme.neonCyan.withOpacity(0.6 + 0.4 * sin(animationValue * pi * 2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
    canvas.drawCircle(center, radius, strokePaint);

    // 3. Draw Deep Cosmic Fade Dark Blue Sphere
    final orbPaint = Paint()
      ..shader = AppTheme.orbGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, orbPaint);

    // 4. Inner Cyan Core Specular Highlight
    final specularPaint = Paint()
      ..color = AppTheme.neonCyan.withOpacity(0.25 + 0.15 * cos(animationValue * pi * 2))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.25, center.dy - radius * 0.25),
      radius * 0.35,
      specularPaint,
    );
  }

  void _drawListeningRipples(Canvas canvas, Offset center, double radius) {
    for (int i = 1; i <= 3; i++) {
      final rippleProgress = (animationValue + (i * 0.33)) % 1.0;
      final rippleRadius = radius + (rippleProgress * radius * 0.8);
      final rippleOpacity = (1.0 - rippleProgress).clamp(0.0, 1.0);

      final ripplePaint = Paint()
        ..color = AppTheme.neonCyan.withOpacity(rippleOpacity * 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, rippleRadius, ripplePaint);
    }
  }

  void _drawThinkingHalo(Canvas canvas, Offset center, double radius) {
    final haloPaint = Paint()
      ..color = AppTheme.electricBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final sweepAngle = pi * 0.7;
    final startAngle = animationValue * pi * 4;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 6),
      startAngle,
      sweepAngle,
      false,
      haloPaint,
    );
  }

  void _drawSpeakingHarmonics(Canvas canvas, Offset center, double radius) {
    final waveCount = 12;
    final angleStep = (pi * 2) / waveCount;
    final wavePaint = Paint()
      ..color = AppTheme.electricBlue.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < waveCount; i++) {
      final angle = i * angleStep;
      final waveLength = 4 + 10 * sin((animationValue * 6) + i);
      final p1 = Offset(
        center.dx + cos(angle) * (radius + 2),
        center.dy + sin(angle) * (radius + 2),
      );
      final p2 = Offset(
        center.dx + cos(angle) * (radius + 2 + waveLength),
        center.dy + sin(angle) * (radius + 2 + waveLength),
      );
      canvas.drawLine(p1, p2, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant OrbPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.state != state;
  }
}
