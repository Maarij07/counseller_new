import 'dart:math';

import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> levels;
  final double heightMultiplier; // Add a height multiplier for scaling
  final double cornerRadius; // Radius for rounded corners

  WaveformPainter(this.levels, {this.heightMultiplier = 1.5, this.cornerRadius = 4.0}); // Default scale is 1.5, cornerRadius is 4.0

  @override
  void paint(Canvas canvas, Size size) {
    if (levels.isEmpty) return;

    final paint = Paint()..color = Colors.white;
    final centerY = size.height / 2;

    final barCount = levels.length;
    const barWidth = 2.0;
    const barSpacing = 2.0;
    final totalBarSpace = barCount * (barWidth + barSpacing);

    const double rightPadding = 0.0;
    final usableWidth = size.width - rightPadding;

    final startX = max((usableWidth - totalBarSpace) / 2, 0);

    for (int i = 0; i < barCount; i++) {
      double level = levels[i];
      double barHeight = (level / 100.0) * (size.height / 2) * heightMultiplier;
      if (barHeight < 1.0) barHeight = 1.0;

      final x = startX + i * (barWidth + barSpacing);
      // Ensure we don't paint beyond usableWidth.
      if (x + barWidth > usableWidth) break;

      final rect = Rect.fromCenter(
        center: Offset(x, centerY),
        width: barWidth,
        height: barHeight * 2,
      );
      // Create a rounded rectangle from the rect
      final rRect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));
      canvas.drawRRect(rRect, paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.levels != levels ||
        oldDelegate.heightMultiplier != heightMultiplier ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}
