import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:senior_project/app_data.dart';
import 'package:senior_project/util/room.dart';

import '../util/constants.dart' as constants;

class MapPainter extends CustomPainter {
  MapPainter({
    this.lineWidth = 2,
    this.pointRadius = 2,
    required this.state,
    this.lineColor = Colors.blue,
    required this.startColor,
    required this.middleColor,
    required this.endColor,
  });

  final InheritedState state;
  final double lineWidth;
  final double pointRadius;
  final Color lineColor;
  final Color startColor;
  final Color middleColor;
  final Color endColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = lineColor
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lineWidth;

    Size imageSize = constants.dimensions[state.currentFloor - 1];
    Offset? pI;
    Offset? pF;
    bool absoluteStart = true;
    bool absoluteEnd = true;

    if (state.start != null && state.start!.floor == state.currentFloor) {
      pI = state.pixelToScreenSpace(imageSize, state.start!.offset);
    }
    if (state.end != null && state.end!.floor == state.currentFloor) {
      pF = state.pixelToScreenSpace(imageSize, state.end!.offset);
    }

    if (state.start != null && state.end != null) {
      Path path = Path();
      List<Room> roomPath = state.start!
          .shortestPath(state, state.end!)
          .path
          .map((name) => state.roomNameMap[name]!)
          .toList();

      int startIndex =
          roomPath.indexWhere((room) => room.floor == state.currentFloor);
      int endIndex =
          roomPath.lastIndexWhere((room) => room.floor == state.currentFloor);

      if (startIndex == -1) return;

      pI = state.pixelToScreenSpace(imageSize, roomPath[startIndex].offset);
      pF = state.pixelToScreenSpace(imageSize, roomPath[endIndex].offset);

      if (startIndex != 0) {
        absoluteStart = false;
      }
      if (endIndex != roomPath.length - 1) {
        absoluteEnd = false;
      }

      path.moveTo(pI.dx, pI.dy);

      for (int i = startIndex + 1; i <= endIndex; i++) {
        Offset p2 = state.pixelToScreenSpace(imageSize, roomPath[i].offset);
        path.lineTo(p2.dx, p2.dy);
      }

      canvas.drawPath(path, paint);
    }

    paint.strokeWidth = pointRadius;

    if (pI != null) {
      paint.color = absoluteStart ? startColor : middleColor;
      canvas.drawPoints(ui.PointMode.points, [pI], paint);
    }
    if (pF != null) {
      paint.color = absoluteEnd ? endColor : middleColor;
      canvas.drawPoints(ui.PointMode.points, [pF], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
