import 'package:get/get.dart';

import '../controllers/gpa_calculation_controller.dart';

class GpaCalculationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GpaCalculationController>(
      () => GpaCalculationController(),
    );
  }
}
