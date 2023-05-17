import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';

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

  /// Returns the shortest path possible between to `end`
  RoomPath shortestPath(HashMap<String, Room> roomNames, Room end) {
    // list of univisited nodes
    List<String> unvisited = roomNames.keys.toList();
    // map of previously visited nodes
    Map<String, String> previous = roomNames.map((key, _) => MapEntry(key, ''));
    // map of distances to nodes
    Map<String, double> distances =
        roomNames.map((key, _) => MapEntry(key, double.infinity));

    distances[name] = 0;

    while (unvisited.isNotEmpty) {
      String key = unvisited
          .reduce((lhs, rhs) => distances[lhs]! < distances[rhs]! ? lhs : rhs);

      unvisited.remove(key);
      Room room = roomNames[key]!;

      for (String nodeId in room.nodes) {
        Room node = roomNames[nodeId]!;
        double distance = room.distanceTo(node) + distances[key]!;

        if (node.type == RoomType.courtyard ||
            node.type == RoomType.classroom) {
          distance = 100 * distance;
        }

        if (distance < distances[nodeId]!) {
          distances[nodeId] = distance;
          previous[nodeId] = key;
        }
      }
    }

    List<String> path = [end.name];
    while (path.last != name) {
      path.add(previous[path.last]!);
    }

    return RoomPath(path.reversed.toList(), distances[end.name]!);
  }

  Room? findNearestOf(HashMap<String, Room> roomNames, RoomType type) {
    var rooms = roomNames.values.where((room) => room.type == type);

    if (rooms.isEmpty) {
      return null;
    }

    return rooms.reduce((lhs, rhs) {
      double leftDist = shortestPath(roomNames, lhs).distance;
      double rightDist = shortestPath(roomNames, rhs).distance;
      return leftDist < rightDist ? lhs : rhs;
    });
  }

  Offset scaledOffset(double scale, {straightening = 10}) => Offset(
      scale * straightening * (x / straightening).round(),
      scale * straightening * (y / straightening).round());
  Offset get offset => Offset(x.toDouble(), y.toDouble());
}
