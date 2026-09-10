import 'package:app_version_update/app_version_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:nust/app/modules/widgets/app_dialog.dart';
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
          final context = Get.context;
          if (context == null) return;
          if (!context.mounted) return;
          showAppConfirmationDialog(
            context: context,
            title: 'Update available',
            message:
                'Install the latest version for portal compatibility and reliability improvements.',
            confirmLabel: 'Update now',
            icon: Icons.system_update_alt_rounded,
          ).then((confirmed) async {
            if (confirmed == true && data.storeUrl != null) {
              await launchUrl(
                Uri.parse(data.storeUrl!),
                mode: LaunchMode.externalApplication,
              );
            }
          });
        }
      });
    } catch (e) {
      debugPrint("Error checking for updates");
    }
  }
}
