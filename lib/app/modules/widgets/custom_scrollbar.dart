import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/theme_controller.dart';

class CustomScrollbar extends StatelessWidget {
  const CustomScrollbar(
      {super.key, required this.child, required this.controller});
  final Widget child;
  final ScrollController controller;
  @override
  Widget build(BuildContext context) {
    ThemeController themeController = Get.find();
    return RawScrollbar(
      thumbColor: themeController.theme.appBarTheme.titleTextStyle?.color,
      padding: const EdgeInsets.only(right: 4),
      thickness: 4,
      thumbVisibility: true,
      radius: const Radius.circular(8),
      controller: controller,
      interactive: true,
      scrollbarOrientation: ScrollbarOrientation.right,
      child: child,
    );
  }
}
