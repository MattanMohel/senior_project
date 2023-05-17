import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senior_project/screens/home.dart';
import 'package:senior_project/util/style.dart';

import 'app_data.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(styleSystem);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: const Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color.fromARGB(255, 249, 253, 255),
        body: AppBase(child: HomeScreen()),
      ),
    ),
  );
}
