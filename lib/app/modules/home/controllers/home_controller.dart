import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:get/get.dart';
import 'package:nust/app/services/stories_service.dart';

class HomeController extends GetxController {
  final CarouselSliderController pageController = CarouselSliderController();
  var activePage = 0.obs;
  var totalPage = 0.obs;
  Rx<List<Map<String, String?>>> topStories =
      Rx<List<Map<String, String?>>>([]);
  final storiesService = StoriesService();
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
    topStories.value = await storiesService.fetchTopStories();
    isLoading.value = false;
  }
}
