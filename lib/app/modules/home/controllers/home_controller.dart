import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/campus_controller.dart';
import 'package:nust/app/controllers/theme_controller.dart';
import '../../../controllers/internet_controller.dart';

class HomeController extends GetxController {
  final CarouselSliderController pageController = CarouselSliderController();
  final activePage = 0.obs;

  final ThemeController themeController = Get.find();
  final CampusController campusController = Get.find();
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
  }

  void _initialize() {
    checkInternet();
  }

  void checkInternet() {
    if (internetController.isOnline.value) {
      fetchStories();
    } else {
      internetController.isOnline.listen((isOnline) {
        if (isOnline) {
          fetchStories();
        } else {
          internetController.noInternetDialog(fetchStories);
        }
      });
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
