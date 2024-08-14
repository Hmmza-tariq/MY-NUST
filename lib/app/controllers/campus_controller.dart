import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
// ignore: library_prefixes
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart';

class CampusController extends GetxController {
  final Dio _dio = Dio();
  final String baseUrl = 'https://nust.edu.pk';
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
  var logo = ''.obs;
  Rx<List<Map<String, String?>>> topStories =
      Rx<List<Map<String, String?>>>([]);

  Future<void> fetchTopStories() async {
    try {
      List<Map<String, String?>> data = [];
      final mainResponse = await _dio.get(baseUrl);
      if (mainResponse.statusCode == 200) {
        String htmlContent = mainResponse.data;
        parseTopStories(htmlContent).forEach((element) {
          data.add(element);
        });
      }
      final otherResponse = await _dio.get(getCampusUrl());
      if (otherResponse.statusCode == 200) {
        String htmlContent = otherResponse.data;
        parseTopStories(htmlContent).forEach((element) {
          data.add(element);
        });
        parseLogo(htmlContent);
      }
      topStories.value = data;
    } catch (e) {
      debugPrint('Error fetching top stories: $e');
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
      print(logo.value);
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
