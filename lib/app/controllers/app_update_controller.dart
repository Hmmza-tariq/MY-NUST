import 'package:app_version_update/app_version_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:nust/app/modules/widgets/custom_button.dart';
import 'package:nust/app/resources/color_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateController extends GetxController {
  var isUpdateAvailable = false.obs;
  final appleId = dotenv.env['APP_STORE_ID'];
  final playStoreId = dotenv.env['PLAY_STORE_ID'];

  @override
  void onInit() {
    super.onInit();
    try {
      AppVersionUpdate.checkForUpdates(
        playStoreId: playStoreId,
        // appleId: appleId,
      ).then((data) {
        if (data.canUpdate!) {
          isUpdateAvailable(true);
          debugPrint('Update Available: ${data.storeVersion}');
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
                onPressed: () async {
                  await launchUrl(Uri.parse(data.storeUrl!),
                      mode: LaunchMode.externalApplication);
                  Get.back();
                },
              ),
            ],
          );
        }
      });
    } catch (e) {
      debugPrint("Error checking for updates");
    }
  }
}
