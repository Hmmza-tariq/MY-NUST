import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/resources/assets_manager.dart';

import '../../controllers/theme_controller.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    required this.details,
    this.height,
    this.width,
    this.roundedBorder,
  });
  final String details;
  final double? height;
  final double? width;
  final bool? roundedBorder;
  @override
  Widget build(BuildContext context) {
    ThemeController themeController = Get.find();
    debugPrint("Error: $details");
    return Container(
      decoration: BoxDecoration(
        color: themeController.theme.scaffoldBackgroundColor,
        borderRadius:
            roundedBorder == true ? BorderRadius.circular(12.0) : null,
      ),
      // padding: const EdgeInsets.all(10.0),
      // margin: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AssetsManager.error,
            fit: BoxFit.fitHeight,
            height: height ?? Get.height * 0.3,
            width: width ?? Get.width,
          ),
          if (details.isNotEmpty)
            Text(
              details,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeController.theme.appBarTheme.titleTextStyle!.color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
