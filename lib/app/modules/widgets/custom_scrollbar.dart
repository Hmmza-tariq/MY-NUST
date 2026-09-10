import 'package:flutter/material.dart';

class CustomScrollbar extends StatelessWidget {
  const CustomScrollbar({
    super.key,
    required this.child,
    required this.controller,
  });

  final Widget child;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) => Scrollbar(
        thickness: 3,
        thumbVisibility: false,
        radius: const Radius.circular(8),
        controller: controller,
        interactive: true,
        child: child,
      );
}
