import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:nust/app/resources/assets_manager.dart';
import 'package:nust/app/resources/color_manager.dart';

var colors = [
  ColorManager.black,
  ColorManager.darkGrey,
  ColorManager.lightGrey,
  ColorManager.lightGrey1,
  ColorManager.primary50,
  ColorManager.lightestPrimary,
  ColorManager.lightPrimary,
  ColorManager.primary,
  ColorManager.primary500,
  ColorManager.darkPrimary,
];

Widget showFullPageLoading(RxInt percentage) {
  return Container(
    color: ColorManager.black.withOpacity(0.5),
    width: Get.width,
    height: Get.height,
    child: Stack(
      alignment: Alignment.center,
      children: [
        if (Platform.isIOS)
          Positioned(
              top: Get.height * 0.05,
              child: Container(
                  width: Get.width * 0.8,
                  decoration: BoxDecoration(
                    color: ColorManager.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'The content of this page is not hosted on our servers. All rights belong to the NUST administration.',
                    textAlign: TextAlign.center,
                  ))),
        Lottie.asset(
          AssetsManager.loading,
          width: Get.width * 0.5,
          height: Get.width * 0.5,
        ),
        Obx(() => Text(
              "${percentage.value}%",
              style: TextStyle(
                color: colors[(percentage.value ~/ 10).clamp(0, 9)],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )),
      ],
    ),
  );
}

Widget showLoading() {
  return Lottie.asset(
    AssetsManager.loading,
    width: Get.width * 0.5,
    height: Get.width * 0.5,
    frameRate: FrameRate.max,
  );
}

Widget heightLoading(double height) {
  return Lottie.asset(
    AssetsManager.loading,
    height: height,
    frameRate: FrameRate.max,
  );
}

void closeLoading() {
  if (Get.isDialogOpen ?? false) Get.back();
}

void errorSnackbar(String message) {
  Get.snackbar(
    'Error',
    message,
    duration: const Duration(seconds: 1),
    snackPosition: SnackPosition.TOP,
    backgroundColor: ColorManager.error.withOpacity(0.8),
    colorText: ColorManager.white,
  );
}

void disclaimerSnackbar(String message) {
  Get.snackbar(
    'Disclaimer',
    message,
    duration: const Duration(seconds: 2),
    snackPosition: SnackPosition.TOP,
    backgroundColor: ColorManager.primary.withOpacity(0.8),
    colorText: ColorManager.white,
  );
}
