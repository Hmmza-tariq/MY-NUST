import 'package:flutter/material.dart';
import 'package:nust/app/resources/assets_manager.dart';
import 'package:nust/app/resources/color_manager.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    required this.details,
  });
  final String details;
  @override
  Widget build(BuildContext context) {
    debugPrint("Error: $details");
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.background2,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AssetsManager.error,
            // width: Get.width * 0.3,
            // height: Get.width * 0.3,
          ),
          const SizedBox(height: 10),
          Text(
            details,
            style: const TextStyle(
              color: ColorManager.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
