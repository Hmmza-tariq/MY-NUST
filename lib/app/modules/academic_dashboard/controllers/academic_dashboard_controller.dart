import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../../../data/academic_dashboard.dart';
import '../../../domain/portal/portal_endpoints.dart';
import '../../../routes/app_pages.dart';
import '../../../services/academic_sync_service.dart';

class AcademicDashboardController extends GetxController {
  final AcademicSyncService syncService = Get.find();
  Rx<AcademicDashboardData> get data => syncService.data;

  String get lmsUrl => PortalEndpoints.lmsFrom(dotenv.env['LMS_URL']);
  String get qalamUrl => PortalEndpoints.qalamFrom(dotenv.env['QALAM_URL']);

  void reloadCache() {
    syncService.reloadCache();
  }

  Future<void> sync() => syncService.syncSavedPortals();

  void openLms() => _openPortal(lmsUrl);
  void openQalam() => _openPortal(qalamUrl);
  void openSettings() => Get.toNamed(Routes.SETTINGS);

  void _openPortal(String url) {
    Get.toNamed(Routes.WEB, parameters: {'url': url})
        ?.then((_) => reloadCache());
  }
}
