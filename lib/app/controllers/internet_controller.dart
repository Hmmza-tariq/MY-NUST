import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

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
}
