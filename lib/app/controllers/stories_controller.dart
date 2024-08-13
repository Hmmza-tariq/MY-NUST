import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
// ignore: library_prefixes
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart';

class StoriesController extends GetxController {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://nust.edu.pk';

  Future<List<Map<String, String?>>> fetchTopStories() async {
    try {
      final response = await _dio.get(_baseUrl);
      if (response.statusCode == 200) {
        String htmlContent = response.data;
        return parseTopStories(htmlContent);
      }
    } catch (e) {
      debugPrint('Error fetching top stories: $e');
    }
    return [];
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
      final storyKey = '${story['title']}${story['imageUrl']}';
      return seenStories.add(storyKey);
    });

    return stories;
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
