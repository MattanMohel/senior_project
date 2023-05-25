import 'package:flutter/material.dart';

class TextScreen extends StatelessWidget {
  const TextScreen({
    super.key,
    this.child,
    required this.title,
  });

  final Widget? child;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.redAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 8.0,
          ),
          child: child,
        ),
      ),
    );
  }
}
