import 'package:flutter/material.dart';

/// A custom widget for displaying success messages.
class SuccessText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const SuccessText(
      this.text, {
        super.key,
        this.textStyle,
        this.textAlign,
        this.maxLines,
        this.overflow,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: const TextStyle(
        color: Colors.green, // Default success color
        fontWeight: FontWeight.w500, // Slightly bolder
      ).merge(textStyle), // Merge with optional custom style
    );
  }
}

/// A custom widget for displaying error messages.
class ErrorText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ErrorText(
      this.text, {
        super.key,
        this.textStyle,
        this.textAlign,
        this.maxLines,
        this.overflow,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: const TextStyle(
        color: Colors.red, // Default error color
        fontWeight: FontWeight.w500, // Slightly bolder
      ).merge(textStyle), // Merge with optional custom style
    );
  }
}

