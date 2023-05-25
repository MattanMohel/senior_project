import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:senior_project/util/constants.dart' as constants;

import '../util/text_screen.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TextScreen(
      title: 'About this App',
      child: Markdown(
        styleSheet: MarkdownStyleSheet(p: const TextStyle(fontSize: 18)),
        data: constants.aboutPageMarkdown,
      ),
    );
  }
}
