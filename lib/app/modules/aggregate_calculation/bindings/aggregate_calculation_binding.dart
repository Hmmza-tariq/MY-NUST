import 'package:get/get.dart';

import '../controllers/aggregate_calculation_controller.dart';

class AggregateCalculationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AggregateCalculationController>(
      () => AggregateCalculationController(),
    );
  }
}
