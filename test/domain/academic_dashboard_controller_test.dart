import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nust/app/data/academic_dashboard.dart';
import 'package:nust/app/modules/academic_dashboard/controllers/academic_dashboard_controller.dart';
import 'package:nust/app/services/academic_sync_service.dart';

class FakeAcademicSync extends GetxService implements AcademicSyncService {
  int reloadCount = 0;
  @override
  final data = const AcademicDashboardData().obs;
  @override
  void reloadCache() {
    reloadCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(Get.reset);
  test(
      'opening Today does not mutate shared Home state during route construction',
      () {
    Get.testMode = true;
    final service =
        Get.put<AcademicSyncService>(FakeAcademicSync()) as FakeAcademicSync;
    Get.put(AcademicDashboardController());
    expect(service.reloadCount, 0);
  });
}
