import 'package:flutter/material.dart';

class FormContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BoxDecoration? decoration;

  const FormContainer({
    super.key,
    required this.child,
    this.width = 400.0, // Default width
    this.height = 600.0, // Default height
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(32.0),
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Center( // Center the container horizontally
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width,
          maxHeight: height,
        ),
        child: Container(
          margin: margin,
          padding: padding,
          decoration: decoration ?? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}