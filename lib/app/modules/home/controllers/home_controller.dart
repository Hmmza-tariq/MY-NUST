import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/stories_controller.dart';
import 'package:nust/app/controllers/theme_controller.dart';

import '../../../controllers/internet_controller.dart';

class HomeController extends GetxController {
  final CarouselSliderController pageController = CarouselSliderController();
  var activePage = 0.obs;
  var totalPage = 0.obs;
  Rx<List<Map<String, String?>>> topStories =
      Rx<List<Map<String, String?>>>([]);

  final ThemeController themeController = Get.find();
  final StoriesController storiesController = Get.find();
  final InternetController internetController = Get.find();

  List<String> campuses = [
    'CEME',
    'MCS',
    'SMME',
    'SEECS',
    'PNEC',
    'NBS',
    'SNS',
    'CAE',
    'NBC',
    'SCME',
    'MCE',
    'IESE',
    'NICE',
    'IGIS',
    'ASAB',
    'SADA',
    'S3H'
  ];
  var selectedCampus = 'CEME'.obs;
  RxBool isLoading = true.obs;
  RxBool isSelectingCampus = false.obs;

  @override
  void onInit() {
    fetchStories();
    super.onInit();
  }

  void fetchStories() async {
    isLoading.value = true;
    internetController.isOnline.listen((isOnline) async {
      if (isOnline) {
        topStories.value = await storiesController.fetchTopStories();
        isLoading.value = false;
      } else {
        Get.snackbar('No Internet', 'Please check your internet connection');
      }
    });
  }
}
