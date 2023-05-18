import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:senior_project/app_data.dart';
import 'package:senior_project/images.dart';
import 'package:senior_project/util/room.dart';

class MapPainter extends CustomPainter {
  MapPainter({
    this.lineWidth = 2,
    this.pointRadius = 2,
    required this.state,
    this.lineColor = Colors.blue,
    required this.startColor,
    required this.endColor,
  });

  final InheritedState state;
  final double lineWidth;
  final double pointRadius;
  final Color lineColor;
  final Color startColor;
  final Color endColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = lineColor
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lineWidth;

    Size imageSize = dimensions[state.currentFloor - 1];
    Offset? pI;
    Offset? pF;

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
      path.moveTo(pI.dx, pI.dy);

      for (int i = startIndex + 1; i <= endIndex; i++) {
        Offset p2 = state.pixelToScreenSpace(imageSize, roomPath[i].offset);
        path.lineTo(p2.dx, p2.dy);
      }

      canvas.drawPath(path, paint);
    }

    paint.strokeWidth = pointRadius;

    if (pI != null) {
      paint.color = startColor;
      canvas.drawPoints(PointMode.points, [pI], paint);
    }
    if (pF != null) {
      paint.color = endColor;
      canvas.drawPoints(PointMode.points, [pF], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
