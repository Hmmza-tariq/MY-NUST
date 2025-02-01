import 'package:get/get.dart';

import '../controllers/absolutes_calculation_controller.dart';

class AbsolutesCalculationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AbsolutesCalculationController>(
      () => AbsolutesCalculationController(),
    );
  }
}
