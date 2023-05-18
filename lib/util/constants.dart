import 'dart:math';

import 'package:url_launcher/url_launcher_string.dart';

const bool debugMode = false;
const double compassOffsset = 40;
const double deg2rad = pi / 180.0;
const String schoolURL =
    'https://sites.google.com/bedfordnhk12.net/bhsbulldogs/home';

Future<void> openLinkInBrowser(String link) async {
  if (await canLaunchUrlString(link)) {
    await launchUrlString(link, mode: LaunchMode.externalNonBrowserApplication);
  } else {
    throw 'unable to open $link';
  }
}
