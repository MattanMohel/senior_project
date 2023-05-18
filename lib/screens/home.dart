import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:senior_project/app_data.dart';
import 'package:senior_project/images.dart';
import 'package:senior_project/util/map.dart';
import 'package:senior_project/util/constants.dart' as constants;
import 'package:senior_project/util/toggle.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../search.dart';
import '../util/background.dart';
import 'about_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  double heading = 0;
  double targetHeading = 0;
  double step = 15;

  late Animation<double> _animation;
  late Tween<double> _tween;
  late AnimationController _controller;

  String _floorImagePath(BuildContext context) {
    int floor = InheritedState.of(context).currentFloor;
    return backgrounds[floor - 1];
  }

  Size _floorImageDim(BuildContext context) {
    int floor = InheritedState.of(context).currentFloor;
    return dimensions[floor - 1];
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _tween = Tween(begin: heading, end: targetHeading);
    _animation = _tween.animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          double target = (step * (targetHeading / step).round()).toDouble();
          double delta = target - heading;

          if (delta > 180) {
            delta -= 360;
          } else if (delta < -180) {
            delta += 360;
          }

          _tween.begin = heading;
          _tween.end = heading + delta;
          _controller.reset();
          _controller.forward();
        }
      })
      ..addListener(() {
        setState(() {
          heading = _animation.value;
        });
      });

    _controller.forward();

    if (!kIsWeb) {
      FlutterCompass.events!.listen((event) {
        targetHeading = event.heading!;
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: InteractiveViewer(
            clipBehavior: Clip.none,
            minScale: 0.5,
            maxScale: 6,
            boundaryMargin: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Stack(
                children: [
                  if (!kIsWeb)
                    CustomPaint(
                      painter: BackgroundPainter(
                        width: 0.2,
                      ),
                    ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(_floorImagePath(context)),
                  ),
                  CustomPaint(
                    painter: MapPainter(
                      state: InheritedState.of(context),
                      lineWidth: 3,
                      pointRadius: 6,
                      startColor: const Color.fromARGB(225, 239, 83, 80),
                      endColor: const Color.fromARGB(225, 102, 187, 106),
                      lineColor: const Color.fromARGB(175, 239, 83, 80),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SlidingUpPanel(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          minHeight: 50,
          maxHeight: 265,
          panel: Column(
            children: [
              const Icon(Icons.drag_handle),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            InheritedState.of(context).decrementFloor(),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    'Floor  ${InheritedState.of(context).currentFloor}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            InheritedState.of(context).incrementFloor(),
                        child: const Icon(
                          Icons.keyboard_arrow_up,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Toggle(
                      onToggle: () {
                        InheritedState.of(context).toggleAccessibility();
                      },
                      toggleValue: () {
                        return InheritedState.of(context).accesibilitySetting;
                      },
                      height: 30,
                      child: const Icon(Icons.accessible),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: PopupMenuButton(
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                onTap: () {},
                                child: Row(
                                  children: const [
                                    Text('  About This App   -  '),
                                    Icon(Icons.question_mark),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const Scaffold(
                                          body: SafeArea(
                                            child: Scaffold(
                                              body: AboutPage(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Row(
                                  children: const [
                                    Text('   User\'s manual    -  '),
                                    Icon(Icons.book),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: () async {
                                  constants
                                      .openLinkInBrowser(constants.schoolURL);
                                },
                                child: Row(
                                  children: const [
                                    Text('  School Website  -  '),
                                    Icon(Icons.link),
                                  ],
                                ),
                              ),
                            ];
                          },
                          child: const Icon(Icons.more_vert)),
                    ),
                  )
                  // const Padding(
                  //   padding: EdgeInsets.only(right: 12.0, left: 4.0),
                  //   child: Icon(Icons.more_vert),
                  // ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Divider(
                  height: 15,
                ),
              ),
              SearchButton(
                hintText: 'Where from?',
                searchType: SearchType.start,
                height: 60,
                horizontalPadding: 10,
                verticalPadding: 10,
                borderRadius: 25,
                leadingIcon: Icons.accessibility_new,
                terms: InheritedState.of(context).rooms,
              ),
              SearchButton(
                hintText: 'Where to?',
                searchType: SearchType.end,
                height: 60,
                horizontalPadding: 10,
                verticalPadding: 10,
                borderRadius: 25,
                leadingIcon: Icons.location_on,
                terms: InheritedState.of(context).rooms,
              ),
            ],
          ),
        ),
        if (!kIsWeb)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 65,
                      child: Image.asset(compassBackground),
                    ),
                    SizedBox(
                      width: 30,
                      child: Transform.rotate(
                        angle: -(_animation.value + constants.compassOffsset) *
                            constants.deg2rad,
                        child: Image.asset(compassArrow),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
