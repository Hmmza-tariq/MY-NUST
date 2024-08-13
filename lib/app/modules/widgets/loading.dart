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
  );
}

void closeLoading() {
  if (Get.isDialogOpen ?? false) Get.back();
}

void snackbar(String message) {
  Get.snackbar(
    'Error',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: ColorManager.error,
    colorText: ColorManager.white,
  );
}
