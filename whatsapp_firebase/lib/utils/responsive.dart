import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    Key? key,
    required this.mobile,
    required this.desktop,
    this.tablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        if (constraint.maxWidth >= 1200) {
          return desktop;
        } else if (constraint.maxWidth >= 800) {
          Widget? resTablet = this.tablet;
          if (resTablet != null) {
            return resTablet;
          } else {
            return desktop;
          }
        } else {
          return mobile;
        }
      },
    );
  }
}
