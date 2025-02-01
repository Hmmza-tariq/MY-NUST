import 'package:get/get.dart';

import '../controllers/aggregate_calculation_controller.dart';

class AbsolutesCalculationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AbsolutesCalculationController>(
      () => AbsolutesCalculationController(),
    );
  }
}
