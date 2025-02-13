import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
// ignore: library_prefixes
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart';
import 'package:nust/app/controllers/database_controller.dart';
import 'package:nust/app/data/story.dart';

class StoriesController extends GetxController {
  final Dio _dio = Dio();
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
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
  var selectedCampus = 'SEECS'.obs;
  var logo = ''.obs;
  RxList<Story> topStories = <Story>[].obs;

  DatabaseController databaseController = Get.find();

  @override
  void onInit() {
    super.onInit();
    selectedCampus.value = databaseController.getCampus();
  }

  void setCampus(String campus) {
    selectedCampus.value = campus;
    databaseController.setCampus(campus);
  }

  Future<bool> fetchTopStories() async {
    try {
      List<Story> data = [];
      final mainResponse = await _dio.get(baseUrl);
      if (mainResponse.statusCode == 200) {
        String htmlContent = mainResponse.data;
        parseTopStories(htmlContent).forEach((element) {
          data.add(Story.fromMap(element));
        });
      }
      final otherResponse = await _dio.get(getCampusUrl());
      if (otherResponse.statusCode == 200) {
        String htmlContent = otherResponse.data;
        parseTopStories(htmlContent).forEach((element) {
          data.add(Story.fromMap(element));
        });
        parseLogo(htmlContent);
      }
      var customStories =
          await databaseController.getDataFromFirebase('custom_stories') ?? [];
      for (var story in customStories) {
        data.add(Story.fromMap(story));
      }

      if (selectedCampus.value == 'CEME') {
        data.add(Story(
          category: 'CEME Monthly Bills',
          title: 'EMEnents can check their monthly bills here',
          imageUrl:
              'https://play-lh.googleusercontent.com/T7oRnv3TYW1RgSPLWL8uvowHlYxhcAI16dRP6i6FfIq3cd-Hn2iJnPLhiETQmKzvzw',
          link: 'https://app.kuickpay.com/PaymentsSearchBill',
        ));
      }
      data.add(Story(
        title: 'NUST News',
        category: 'NUST',
        imageUrl: 'assets/images/nust_logo.png',
        link: baseUrl,
      ));
      topStories.value = data;
      return true;
    } catch (e) {
      debugPrint('Error fetching top stories: $e');
      return false;
    }
  }

  List<Map<String, String?>> parseTopStories(String htmlContent) {
    Document document = htmlParser.parse(htmlContent);
    List<Element> storyElements =
        document.querySelectorAll('#top_stories_news .item');

    List<Map<String, String?>> stories = [];

    for (var element in storyElements) {
      String? imageUrl;
      var imgElement = element.querySelector('.image_container img');
      if (imgElement != null) {
        imageUrl = imgElement.attributes['src'];

        if (imageUrl != null && imageUrl.startsWith('data:image')) {
          imageUrl = imgElement.attributes['data-lazy-src'] ??
              imgElement.attributes['data-src'] ??
              imgElement.attributes['data-original'];
        }
      }

      if (imageUrl == null) {
        String? style = element.attributes['style'];
        if (style != null) {
          RegExp urlPattern = RegExp(r'background:url\((.*?)\);');
          imageUrl = urlPattern.firstMatch(style)?.group(1);
        }
      }

      String? title = element.querySelector('#item-title')?.text;
      String? category = element.querySelector('#item-category')?.text;
      String? link =
          element.querySelector('.item-detials a')?.attributes['href'];

      stories.add({
        'title': title,
        'category': category,
        'imageUrl': imageUrl,
        'link': link,
      });
    }
    final seenStories = <String>{};
    stories.retainWhere((story) {
      final storyKey = '${story['imageUrl']}';
      return seenStories.add(storyKey);
    });

    return stories;
  }

  void parseLogo(String htmlContent) {
    try {
      logo.value = htmlParser
              .parse(htmlContent)
              .querySelector('.logo-school')!
              .attributes['src'] ??
          '';
    } catch (e) {
      debugPrint('Error parsing logo: $e');
    }
  }

  String getCampusUrl() {
    return 'https://${selectedCampus.value}.${baseUrl.split("//")[1]}';
  }

  void debugPrintStories(List<Map<String, String?>> stories) {
    for (var story in stories) {
      debugPrint('Title: ${story['title']}');
      debugPrint('Date: ${story['date']}');
      debugPrint('Image URL: ${story['imageUrl']}');
      debugPrint('Link: ${story['link']}');
      debugPrint('Category: ${story['category']}');
      debugPrint('---');
    }
  }
}
