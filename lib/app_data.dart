import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senior_project/images.dart';
import 'package:senior_project/util/room.dart';

class InheritedState extends InheritedWidget {
  const InheritedState({
    super.key,
    required this.appState,
    required this.size,
    required super.child,
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
  const AppBase({super.key, required this.child});
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
    for (int i = 0; i < floorCount; i++) {
      _toRoomJson(jsons[i]);
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
    if (_floor == floorCount) {
      setState(() => _floor = 1);
      return;
    }
    setState(() => _floor += 1);
  }

  void _decrementFloor() {
    if (_floor == 1) {
      setState(() => _floor = floorCount);
      return;
    }
    setState(() => _floor -= 1);
  }

  void _toggleAccessibility() {
    setState(() => _accessibility = !_accessibility);
  }

  void _setStartPoint(Room? start) {
    setState(() => _start = start);
  }

  void _setEndPoint(Room? end) {
    setState(() => _end = end);
  }
}
