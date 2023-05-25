import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:senior_project/util/text_screen.dart';
import 'package:senior_project/util/constants.dart' as constants;

class ManualPage extends StatelessWidget {
  const ManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TextScreen(
      title: 'User\'s Manual',
      child: Markdown(
        styleSheet: MarkdownStyleSheet(p: const TextStyle(fontSize: 18)),
        data: constants.manualMarkdown,
      ),
    );
  }
}
