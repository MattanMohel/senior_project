import 'dart:ui';

import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  BackgroundPainter({
    this.width = 0.5,
    this.color = Colors.black26,
    this.lineDensity = 35,
  });

  final double width;
  final Color color;
  final int lineDensity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width;

    Size screen = window.physicalSize;
    for (double i = -screen.height; i < screen.height; i += lineDensity) {
      canvas.drawLine(
        Offset(-2 * screen.width, i),
        Offset(2 * screen.width, i),
        paint,
      );
    }

    for (double i = -2 * screen.width; i < 2 * screen.width; i += lineDensity) {
      canvas.drawLine(
        Offset(i, -screen.height),
        Offset(i, screen.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
