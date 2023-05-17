import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:senior_project/app_data.dart';
import 'package:senior_project/images.dart';
import 'package:senior_project/util/room.dart';

class MapPainter extends CustomPainter {
  MapPainter({
    required this.context,
    this.lineWidth = 2,
    this.pointRadius = 2,
    this.lineColor = Colors.blue,
    required this.startColor,
    required this.endColor,
  });

  final BuildContext context;
  final double lineWidth;
  final double pointRadius;
  final Color lineColor;
  final Color startColor;
  final Color endColor;

  @override
  void paint(Canvas canvas, Size size) {
    InheritedState state = InheritedState.of(context);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = lineColor
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lineWidth;

    // if (style.debugMode) {
    //   var rooms = roomNames.values.where((room) => room.floor == currentFloor);
    //   for (Room room in rooms) {
    //     Offset p1 = pixelToScreenSpace(imageSize, windowSize, room.offset);
    //     var nodes = room.nodes
    //         .map((name) => roomNames[name]!)
    //         .where((node) => node.floor == currentFloor);

    //     for (var node in room.nodes) {
    //       if (!roomNames.containsKey(node)) {
    //         debugPrint(node);
    //       }
    //     }
    //     for (Room node in nodes) {
    //       Offset p2 = pixelToScreenSpace(imageSize, windowSize, node.offset);
    //       canvas.drawLine(p1, p2, paint);
    //     }
    //   }
    // }
    Size imageSize = dimensions[state.currentFloor - 1];

    if (state.start != null && state.end != null) {
      Path path = Path();
      List<Room> roomPath = state.start!
          .shortestPath(state.roomNameMap, state.end!)
          .path
          .map((name) => state.roomNameMap[name]!)
          .toList();

      int startIndex =
          roomPath.indexWhere((room) => room.floor == state.currentFloor);
      int endIndex =
          roomPath.lastIndexWhere((room) => room.floor == state.currentFloor);

      if (startIndex == -1 || endIndex == -1) return;

      Offset p1 =
          state.pixelToScreenSpace(imageSize, roomPath[startIndex].offset);

      path.moveTo(p1.dx, p1.dy);

      for (Room room
          in roomPath.skip(startIndex + 1).take(endIndex - startIndex)) {
        Offset p2 = state.pixelToScreenSpace(imageSize, room.offset);
        path.lineTo(p2.dx, p2.dy);
      }

      paint.color = lineColor;
      canvas.drawPath(path, paint);

      if (startIndex != 0) {
        canvas.drawPoints(
            PointMode.points,
            [state.pixelToScreenSpace(imageSize, roomPath[startIndex].offset)],
            paint);
      }
      if (endIndex != roomPath.length - 1) {
        canvas.drawPoints(
            PointMode.points,
            [state.pixelToScreenSpace(imageSize, roomPath[endIndex].offset)],
            paint);
      }
    }

    if (state.start != null && state.start!.floor == state.currentFloor) {
      paint.color = startColor;
      canvas.drawPoints(PointMode.points,
          [state.pixelToScreenSpace(imageSize, state.start!.offset)], paint);
    }
    if (state.end != null && state.end!.floor == state.currentFloor) {
      paint.color = endColor;
      canvas.drawPoints(PointMode.points,
          [state.pixelToScreenSpace(imageSize, state.end!.offset)], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
