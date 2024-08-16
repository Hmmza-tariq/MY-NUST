import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../resources/color_manager.dart';
import '../controllers/aggregate_calculation_controller.dart';

class AggregateCalculationView extends GetView<AggregateCalculationController> {
  const AggregateCalculationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => Scaffold(
            backgroundColor:
                controller.themeController.theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  gradient: ColorManager.gradientColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: ColorManager.primary,
                          ),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                        const Spacer(),
                        const SizedBox(width: 8),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Aggregate Calculation is coming soon!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: controller.themeController.theme.appBarTheme
                            .titleTextStyle!.color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
