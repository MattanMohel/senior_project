import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senior_project/screens/home.dart';
import 'package:senior_project/util/constants.dart' as constants;

import 'app_data.dart';

// ! launch_review

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(constants.styleSystem);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color.fromARGB(255, 249, 253, 255),
        body: AppBase(
          child: HomeScreen(),
        ),
      ),
    ),
  );
}
