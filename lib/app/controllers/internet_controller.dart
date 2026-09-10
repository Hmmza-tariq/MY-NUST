import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/widgets/app_dialog.dart';

class InternetController extends GetxController {
  var isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    Connectivity().onConnectivityChanged.listen((var result) {
      if (result[0] == ConnectivityResult.none) {
        isOnline(false);
        // debugPrint('No internet available');
      } else {
        isOnline(true);
        // debugPrint('Internet available');
      }
    });
  }

  Future<void> noInternetDialog(void Function()? onPressed) async {
    if (Get.isDialogOpen == false) {
      final context = Get.context;
      if (context == null) return;
      final retry = await showAppConfirmationDialog(
        context: context,
        title: 'You’re offline',
        message:
            'Check your connection, then retry. Calculators remain available offline.',
        confirmLabel: 'Retry',
        cancelLabel: 'Not now',
        icon: Icons.cloud_off_outlined,
      );
      if (retry == true) onPressed?.call();
    }
  }
}
