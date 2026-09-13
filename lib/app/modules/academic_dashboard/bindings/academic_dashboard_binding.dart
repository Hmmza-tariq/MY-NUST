import 'package:get/get.dart';

import '../controllers/academic_dashboard_controller.dart';

class AcademicDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AcademicDashboardController>(
        () => AcademicDashboardController());
  }
}
