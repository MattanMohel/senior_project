import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senior_project/util/constants.dart' as constants;
import 'package:senior_project/util/room.dart';

class InheritedState extends InheritedWidget {
  const InheritedState({
    super.key,
    required super.child,
    required this.appState,
    required this.size,
  });

  final AppBaseState appState;
  final Size size;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  static InheritedState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedState>()!;
  }

  // getters

  Size get windowSize => size;
  int get currentFloor => appState._floor;
  bool get accesibilitySetting => appState._accessibility;
  Room? get start => appState._start;
  Room? get end => appState._end;
  List<Room> get rooms => appState._rooms;
  HashMap<String, Room> get roomNameMap => appState._roomNames;
  List<String> get roomNames => roomNameMap.keys.toList();

  // setters

  void setStartPoint(Room? start) => appState._setStartPoint(start);
  void setEndPoint(Room? end) => appState._setEndPoint(end);
  void toggleAccessibility() => appState._toggleAccessibility();
  void incrementFloor() => appState._incrementFloor();
  void decrementFloor() => appState._decrementFloor();

  String roomIdentifier(Room room) {
    if (room.type == RoomType.none) {
      return "Passage Point";
    }

    return room.name;
  }

  Room? closestRoomTo(double x, double y) {
    double xPx = constants.dimensions[currentFloor - 1].width * x;
    double yPx = constants.dimensions[currentFloor - 1].height * y;

    Room closest = rooms.reduce((r1, r2) {
      double d1 = sqrt(pow(r1.x - xPx, 2) + pow(r1.y - yPx, 2));
      double d2 = sqrt(pow(r2.x - xPx, 2) + pow(r2.y - yPx, 2));

      if (r1.floor != currentFloor) {
        return r2;
      }
      if (r2.floor != currentFloor) {
        return r1;
      }

      return d1 < d2 ? r1 : r2;
    });

    double distance = sqrt(pow(closest.x - xPx, 2) + pow(closest.y - yPx, 2));
    return distance < 150 ? closest : null;
  }

  // path computation

  RoomPath getShortestPath(Room end) => start!.shortestPath(this, end);
  Room? getNearestOf(RoomType type) => start!.findNearestOf(this, type);
  List<Room> getRoomsOfFloor(int floor) {
    return rooms.where((room) => room.floor - 1 == floor).toList();
  }

  // conversions

  Offset pixelToScreenSpace(Size pixels, Offset px) {
    return Offset(px.dx * (size.width / pixels.width),
        px.dy * (size.width / pixels.width));
  }
}

class AppBase extends StatefulWidget {
  const AppBase({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  State<StatefulWidget> createState() => AppBaseState();
}

class AppBaseState extends State<AppBase> {
  final List<Room> _rooms = [];
  final HashMap<String, Room> _roomNames = HashMap();
  int _floor = 1;
  bool _accessibility = false;
  Room? _start;
  Room? _end;

  @override
  Widget build(BuildContext context) {
    return InheritedState(
      appState: this,
      size: MediaQuery.of(context).size,
      child: widget.child,
    );
  }

  @override
  void initState() {
    for (int i = 0; i < constants.floorCount; i++) {
      _toRoomJson(constants.jsons[i]);
    }
    super.initState();
  }

  void _toRoomJson(String jsonPath) async {
    String source = '';

    try {
      source = await rootBundle.loadString(jsonPath);
    } catch (_) {
      debugPrint('file not found');
    }

    var data = jsonDecode(source);

    for (var roomData in data) {
      List<String> nodes = (roomData['nodes'] as List)
          .map((element) => element as String)
          .toList();

      RoomType roomType = RoomType.getType(roomData['room_type']);

      Room room = Room(
        roomData['id'],
        roomData['floor'],
        roomData['x'] as int,
        roomData['y'] as int,
        roomData['description'],
        roomType,
        nodes,
      );

      _roomNames[room.name] = room;
      setState(() => _rooms.add(room));
    }
  }

  void _incrementFloor() {
    if (_floor == constants.floorCount) {
      setState(() => _floor = 1);
      return;
    }
    setState(() => _floor += 1);
  }

  void _decrementFloor() {
    if (_floor == 1) {
      setState(() => _floor = constants.floorCount);
      return;
    }
    setState(() => _floor -= 1);
  }

  void _toggleAccessibility() {
    setState(() => _accessibility = !_accessibility);
  }

  void _setStartPoint(Room? start) {
    if (start != null) {
      if (_end != null && start.name == _end!.name) {
        _end = null;
      }

      _floor = start.floor;
    }
    setState(() => _start = start);
  }

  void _setEndPoint(Room? end) {
    if (_start != null && end != null && _start!.name == end.name) {
      _start = null;
    }
    setState(() => _end = end);
  }
}
