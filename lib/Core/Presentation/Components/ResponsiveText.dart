import 'package:flutter/material.dart';

class ResponsiveText extends StatelessWidget {
  final String text;

  const ResponsiveText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = constraints.maxWidth < 200 ? 12.0 : 14.0;
        return Text(
          text,
          style: TextStyle(fontSize: fontSize),
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}