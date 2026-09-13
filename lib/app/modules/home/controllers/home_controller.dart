import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/stories_controller.dart';
import 'package:nust/app/controllers/theme_controller.dart';
import 'package:nust/app/domain/portal/portal_endpoints.dart';
import '../../../controllers/internet_controller.dart';
import '../../../services/notification_service.dart';
import '../../../services/academic_sync_service.dart';
import '../../../controllers/database_controller.dart';
import '../../../routes/app_pages.dart';
import '../../widgets/portal_sync_setup_dialog.dart';

class HomeController extends GetxController {
  final CarouselSliderController pageController = CarouselSliderController();
  final activePage = 0.obs;

  final ThemeController themeController = Get.find();
  final StoriesController campusController = Get.find();
  final InternetController internetController = Get.find();

  late final String lmsUrl = PortalEndpoints.lmsFrom(dotenv.env['LMS_URL']);
  late final String qalamUrl =
      PortalEndpoints.qalamFrom(dotenv.env['QALAM_URL']);

  final RxBool isLoading = true.obs;
  final RxBool isError = false.obs;
  final RxBool isSelectingCampus = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
    NotificationsService().init(Get.context!);
  }

  void _initialize() {
    // Don't show loading if we have cached data
    if (campusController.topStories.isNotEmpty) {
      isLoading.value = false;
    }
    checkInternet();
  }

  @override
  void onReady() {
    super.onReady();
    _setupAcademicSync();
  }

  Future<void> _setupAcademicSync() async {
    final database = Get.find<DatabaseController>();
    final sync = Get.find<AcademicSyncService>();
    if (!database.getAcademicSetupSeen() && Get.context != null) {
      final enabled = await showPortalSyncSetup(Get.context!);
      await database.setAcademicSetupSeen();
      if (enabled == true) {
        await sync.setAutomaticSync(true);
        if (!sync.canAutoSync) await Get.toNamed(Routes.SETTINGS);
      }
    }
    if (!isClosed) await sync.syncOnOpen();
  }

  void checkInternet() {
    if (internetController.isOnline.value) {
      // Fetch fresh data silently in background if we have internet
      fetchStoriesInBackground();
    } else {
      // If offline but have cached data, don't show dialog - just show cache
      if (campusController.topStories.isEmpty) {
        internetController.isOnline.listen((isOnline) {
          if (isOnline) {
            fetchStoriesInBackground();
          } else {
            internetController.noInternetDialog(fetchStories);
          }
        });
      } else {
        // Have cache, listen for internet and fetch when available
        internetController.isOnline.listen((isOnline) {
          if (isOnline) {
            fetchStoriesInBackground();
          }
        });
      }
    }
  }

  // Silent background fetch - doesn't show loading spinner
  Future<void> fetchStoriesInBackground() async {
    try {
      // Show loading only if no cached data exists
      if (campusController.topStories.isEmpty) {
        isLoading.value = true;
      }
      await campusController.fetchTopStories();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStories() async {
    await refreshAll();
  }

  Future<void> refreshAll() async {
    if (!internetController.isOnline.value) {
      internetController.noInternetDialog(fetchStories);
      return;
    }

    isLoading.value = true;

    activePage.value = 0;
    try {
      await Future.wait([
        campusController
            .fetchTopStories()
            .then((success) => isError.value = !success),
        if (Get.find<AcademicSyncService>().canAutoSync)
          Get.find<AcademicSyncService>().syncSavedPortals(),
      ]);
    } finally {
      isLoading.value = false;
      activePage.value = 0;
    }
  }
}
