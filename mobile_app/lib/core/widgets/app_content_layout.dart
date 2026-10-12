import 'package:flutter/material.dart';

import '../../app/theme/app_breakpoints.dart';

class AppContentLayout extends StatelessWidget {
  const AppContentLayout({
    super.key,
    required this.child,
    this.maxWidth,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final double? maxWidth;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final contentWidth =
            maxWidth ??
            (availableWidth >= AppBreakpoints.desktop
                ? 1080.0
                : availableWidth >= AppBreakpoints.tablet
                ? 820.0
                : availableWidth);

        return Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: child,
          ),
        );
      },
    );
  }
}
