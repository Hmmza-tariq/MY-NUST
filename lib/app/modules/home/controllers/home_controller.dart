import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/stories_controller.dart';
import 'package:nust/app/controllers/theme_controller.dart';
import '../../../controllers/internet_controller.dart';
import '../../../services/notification_service.dart';

class HomeController extends GetxController {
  final CarouselSliderController pageController = CarouselSliderController();
  final activePage = 0.obs;

  final ThemeController themeController = Get.find();
  final StoriesController campusController = Get.find();
  final InternetController internetController = Get.find();

  final String lmsUrl = dotenv.env['LMS_URL'] ?? '';
  final String qalamUrl = dotenv.env['QALAM_URL'] ?? '';

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

  void fetchStories() async {
    if (!internetController.isOnline.value) {
      return internetController.noInternetDialog(fetchStories);
    }

    isLoading.value = true;

    Future.delayed(const Duration(milliseconds: 300), () {
      pageController.animateToPage(0);
    });
    activePage.value = 0;
    try {
      isError.value = !await campusController.fetchTopStories();
    } finally {
      isLoading.value = false;
      pageController.animateToPage(0);
      activePage.value = 0;
    }
  }
}
