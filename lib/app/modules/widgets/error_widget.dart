import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/resources/assets_manager.dart';
import 'package:nust/app/resources/color_manager.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    required this.details,
  });
  final FlutterErrorDetails details;
  @override
  Widget build(BuildContext context) {
    debugPrint("Error: ${details.exceptionAsString()}");
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.background2,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.all(10.0),
      child: Image.asset(
        AssetsManager.error,
        width: Get.width * 0.3,
        height: Get.width * 0.3,
      ),
    );
  }
}
