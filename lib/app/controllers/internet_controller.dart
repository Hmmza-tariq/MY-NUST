import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../modules/widgets/custom_button.dart';
import '../resources/color_manager.dart';

class InternetController extends GetxController {
  var isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    Connectivity().onConnectivityChanged.listen((var result) {
      if (result[0] == ConnectivityResult.none) {
        isOnline(false);
        print('No internet');
      } else {
        isOnline(true);
        print('Internet');
      }
    });
  }

  Future<void> noInternetDialog(void Function()? onPressed) async {
    await Get.defaultDialog(
        title: 'No Internet',
        middleText: 'Please check your internet connection and try again.',
        confirm: CustomButton(
          title: "Retry",
          color: ColorManager.primary,
          textColor: ColorManager.white,
          widthFactor: 1,
          onPressed: () {
            onPressed?.call();
            Get.back();
          },
        ));
  }
}
