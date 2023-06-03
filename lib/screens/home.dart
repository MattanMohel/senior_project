import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:senior_project/app_data.dart';
import 'package:senior_project/screens/manual_page.dart';
import 'package:senior_project/screens/map.dart';
import 'package:senior_project/util/constants.dart' as constants;
import 'package:senior_project/util/toggle.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../util/room.dart';
import 'search.dart';
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

  final PanelController _panelController = PanelController();
  final GlobalKey _key = GlobalKey();

  late Animation<double> _animation;
  late Tween<double> _tween;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _tween = Tween(begin: heading, end: targetHeading);
    _animation = _tween.animate(_animationController)
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
          _animationController.reset();
          _animationController.forward();
        }
      })
      ..addListener(() {
        setState(() {
          heading = _animation.value;
        });
      });

    _animationController.forward();

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
            boundaryMargin: const EdgeInsets.all(60),
            child: Align(
              alignment: Alignment.topLeft,
              child: Stack(
                children: [
                  if (!kIsWeb || !constants.optimizeWeb)
                    CustomPaint(
                      painter: BackgroundPainter(
                        width: 0.2,
                      ),
                    ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      key: _key,
                      onTapUp: (details) {
                        Rect size = (_key.currentContext?.findRenderObject()
                                as RenderBox)
                            .paintBounds;

                        double x = details.localPosition.dx / size.width;
                        double y = details.localPosition.dy / size.height;

                        Room? closestQuery =
                            InheritedState.of(context).closestRoomTo(x, y);

                        if (closestQuery != null) {
                          _showSelectionPopupMenu(context, closestQuery);
                        }
                      },
                      child: Image.asset(
                        constants.backgrounds[
                            InheritedState.of(context).currentFloor - 1],
                      ),
                    ),
                  ),
                  CustomPaint(
                    painter: MapPainter(
                      state: InheritedState.of(context),
                      lineWidth: 3.5,
                      pointRadius: 8,
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
          controller: _panelController,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          minHeight: 90,
          maxHeight: 265,
          defaultPanelState: PanelState.OPEN,
          backdropEnabled: true,
          backdropOpacity: 0.2,
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Material(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(4.0),
                          ),
                        ),
                        color: Colors.grey[75],
                        child: InkWell(
                          onTap: () =>
                              InheritedState.of(context).decrementFloor(),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_downward,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Floor  ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                      children: [
                        TextSpan(
                          text: InheritedState.of(context)
                              .currentFloor
                              .toString(),
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Material(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(4.0),
                          ),
                        ),
                        color: Colors.grey[75],
                        child: InkWell(
                          onTap: () =>
                              InheritedState.of(context).incrementFloor(),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_upward,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Toggle(
                    onToggle: () {
                      InheritedState.of(context).toggleAccessibility();
                    },
                    toggleValue: () {
                      return InheritedState.of(context).accesibilitySetting;
                    },
                    height: 30,
                    width: _panelController.isAttached
                        ? 75 * _panelController.panelPosition
                        : 0,
                    child: const Center(
                      child: Icon(Icons.accessible),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    width: _panelController.isAttached
                        ? 50 * _panelController.panelPosition
                        : 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: PopupMenuButton(
                          clipBehavior: Clip.hardEdge,
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                onTap: () {
                                  Future(
                                    () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const AboutPage(),
                                      ),
                                    ),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Text('  About this app   -  '),
                                    Icon(Icons.help_center),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: () {
                                  Future(
                                    () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const ManualPage(),
                                      ),
                                    ),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Text('   User\'s manual   -  '),
                                    Icon(Icons.book),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: () async {
                                  constants
                                      .openLinkInBrowser(constants.schoolURL);
                                },
                                child: const Row(
                                  children: [
                                    Text('  School website  -  '),
                                    Icon(Icons.link),
                                  ],
                                ),
                              ),
                            ];
                          },
                          child: const Icon(Icons.more_vert)),
                    ),
                  )
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
                      child: Image.asset(constants.compassBackground),
                    ),
                    SizedBox(
                      width: 30,
                      child: Transform.rotate(
                        angle: (_animation.value + constants.compassOffsset) *
                            constants.deg2rad,
                        child: Image.asset(constants.compassArrow),
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

  void _showSelectionPopupMenu(BuildContext context, Room closest) async {
    await showMenu(
      context: context,
      position: RelativeRect.fill,
      items: [
        PopupMenuItem(
          child: const Row(
            children: [Icon(Icons.accessibility_new), Text('   As Location')],
          ),
          onTap: () => InheritedState.of(context).setStartPoint(closest),
        ),
        PopupMenuItem(
            child: const Row(
              children: [
                Icon(Icons.location_on),
                Text('   As Destination'),
              ],
            ),
            onTap: () => InheritedState.of(context).setEndPoint(closest)),
      ],
      elevation: 8.0,
    );
  }
}
