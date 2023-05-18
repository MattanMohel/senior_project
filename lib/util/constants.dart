import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

const bool debugMode = false;
const double compassOffsset = 48;
const double deg2rad = pi / 180.0;
const String schoolURL =
    'https://sites.google.com/bedfordnhk12.net/bhsbulldogs/home';

const String compassBackground = 'assets/images/background.png';
const String compassArrow = 'assets/images/arrow.png';
const int floorCount = 3;

const List<Size> dimensions = [
  Size(1628, 2238),
  Size(1561, 2042),
  Size(1599, 1717),
];

const List<String> backgrounds = [
  'assets/Floor 1/bg.PNG',
  'assets/Floor 2/bg.PNG',
  'assets/Floor 3/bg.PNG',
];

const List<String> jsons = [
  'assets/Floor 1/floor-1.json',
  'assets/Floor 2/floor-2.json',
  'assets/Floor 3/floor-3.json',
];

final List<BoxShadow> styleBoxShadow = kElevationToShadow[2]!;

const SystemUiOverlayStyle styleSystem = SystemUiOverlayStyle(
  systemNavigationBarColor: Colors.white,
  statusBarColor: Colors.black26,
);

Future<void> openLinkInBrowser(String link) async {
  if (await canLaunchUrlString(link)) {
    await launchUrlString(link, mode: LaunchMode.externalNonBrowserApplication);
  } else {
    throw 'unable to open $link';
  }
}
