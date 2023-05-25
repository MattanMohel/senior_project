import 'dart:math';

import 'package:flutter/material.dart';
import 'package:senior_project/app_data.dart';

/// enum of possible room types
enum RoomType {
  stairs,
  office,
  bathroom,
  exit,
  classroom,
  misc,
  courtyard,
  elevator,
  none;

  static RoomType getType(String name) {
    switch (name.toLowerCase()) {
      case 'stairs':
        return RoomType.stairs;
      case 'office':
        return RoomType.office;
      case 'bathroom':
        return RoomType.bathroom;
      case 'exit':
        return RoomType.exit;
      case 'class':
        return RoomType.classroom;
      case 'elevator':
        return RoomType.elevator;
      case 'misc':
        return RoomType.misc;
      case 'courtyard':
        return RoomType.courtyard;
      default:
        return RoomType.none;
    }
  }
}

class RoomPath {
  const RoomPath(this.path, this.distance);
  final List<String> path;
  final double distance;
}

class Room {
  const Room(this.name, this.floor, this.x, this.y, this.description, this.type,
      this.nodes);

  final String name;
  final int floor;
  final int x;
  final int y;
  final String description;
  final RoomType type;
  final List<String> nodes;

  @override
  int get hashCode => name.hashCode + floor.hashCode;

  @override
  bool operator ==(Object other) {
    return super.hashCode == other.hashCode;
  }

  /// Returns the room's distance to `other`
  double distanceTo(Room other) {
    return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));
  }

  /// Returns the shortest possible path possible between [self]
  /// and [end] given the inherited state of the application and
  /// using Dijkstra's path-finding algorithm
  RoomPath shortestPath(InheritedState state, Room end) {
    // a list of all unvisited nodes
    List<String> unvisited = state.roomNameMap.keys.toList();
    // a list of all previously visited nodes
    Map<String, String> previous =
        state.roomNameMap.map((key, _) => MapEntry(key, ''));
    // a list of shortest distances to all nodes
    Map<String, double> distances =
        state.roomNameMap.map((key, _) => MapEntry(key, double.infinity));

    distances[name] = 0;

    while (unvisited.isNotEmpty) {
      String key = unvisited
          .reduce((lhs, rhs) => distances[lhs]! < distances[rhs]! ? lhs : rhs);

      unvisited.remove(key);

      Room p1 = state.roomNameMap[key]!;

      for (String nodeId in p1.nodes) {
        Room p2 = state.roomNameMap[nodeId]!;
        double distance = p1.distanceTo(p2) + distances[key]!;

        // if path passes through another classroom
        bool b1 = p2.type == RoomType.classroom && end != p2;
        // if path passes through the courtyard
        bool b2 = p2.type == RoomType.courtyard && end != p2;
        // if path passes through elevator while accessibility setting are disabled
        bool b3 = p2.type == RoomType.elevator && !state.accesibilitySetting;
        // if path finds a shorter route by unecessarily changing floors using stairs
        bool b4 = p2.type == RoomType.stairs && floor == end.floor;
        // if path finds a shorter route by unecessarily changing floors using an elevator
        bool b5 = p2.type == RoomType.elevator && floor == end.floor;
        // if path passes through stairs when accessibility settings are enabled
        bool b6 = p2.type == RoomType.stairs && state.accesibilitySetting;

        if (b1 || b2 || b3 || b4 || b5 || b6) {
          distance = double.maxFinite;
        }

        // update path if current connection is shorter
        if (distance < distances[nodeId]!) {
          distances[nodeId] = distance;
          previous[nodeId] = key;
        }
      }
    }

    // iterate backwards to assemble the path
    List<String> path = [end.name];
    while (path.last != name) {
      path.add(previous[path.last]!);
    }

    return RoomPath(path.reversed.toList(), distances[end.name]!);
  }

  Room? findNearestOf(InheritedState state, RoomType type) {
    Iterable<Room> rooms = state.rooms.where((room) => room.type == type);
    if (rooms.isEmpty) {
      return null;
    }

    return rooms.reduce((lhs, rhs) {
      double leftDist = shortestPath(state, lhs).distance;
      double rightDist = shortestPath(state, rhs).distance;
      return leftDist < rightDist ? lhs : rhs;
    });
  }

  Offset get offset => Offset(x.toDouble(), y.toDouble());
}
