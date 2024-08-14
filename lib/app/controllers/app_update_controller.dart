import 'package:app_version_update/app_version_update.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/modules/widgets/custom_button.dart';
import 'package:nust/app/resources/color_manager.dart';

class AppUpdateController extends GetxController {
  var isUpdateAvailable = false.obs;
  final appleId = '6478523748';
  final playStoreId = 'com.hexagone.green_eats';

  @override
  void onInit() async {
    super.onInit();

    await AppVersionUpdate.checkForUpdates(
            appleId: appleId, playStoreId: playStoreId)
        .then((data) async {
      print(data.storeUrl);
      print(data.storeVersion);
      if (data.canUpdate!) {
        isUpdateAvailable(true);
        print('Update Available');
        // AppVersionUpdate.showAlertUpdate(
        //   appVersionResult: data,
        //   context: Get.context,
        //   mandatory: true,
        //   title: 'Update Available',
        //   content:
        //       'A new version of the app is available. Please update to the latest version.',
        //   backgroundColor: ColorManager.background1,
        //   titleTextStyle: const TextStyle(color: ColorManager.primary),
        //   contentTextStyle: const TextStyle(color: ColorManager.primary),
        //   updateTextStyle: const TextStyle(color: ColorManager.primary),
        // );
        Get.defaultDialog(
          title: 'Update Available',
          titleStyle: const TextStyle(color: ColorManager.primary),
          content: const Text(
              'A new version of the app is available. Please update to the latest version.'),
          backgroundColor: ColorManager.background1,
          actions: [
            CustomButton(
              title: "Cancel",
              color: ColorManager.background1,
              textColor: ColorManager.primary,
              widthFactor: 1,
              onPressed: () {
                Get.back();
              },
            ),
            CustomButton(
              title: "Update",
              color: ColorManager.primary,
              textColor: ColorManager.white,
              widthFactor: 1,
              onPressed: () {
                // AppVersionUpdate.
              },
            ),
          ],
        );
      }
    });
  }
}
