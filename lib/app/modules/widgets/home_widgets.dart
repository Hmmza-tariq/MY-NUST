import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nust/app/resources/color_manager.dart';
import 'package:nust/app/routes/app_pages.dart';

import 'loading.dart';

class HomeSmallButton extends StatelessWidget {
  const HomeSmallButton({
    super.key,
    required this.title,
    required this.icon,
    required this.page,
  });
  final String title;
  final String icon;
  final String page;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed(page);
      },
      child: Container(
        width: Get.width * 0.23,
        height: 70,
        // padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: ColorManager.background2,
          border: Border.all(color: ColorManager.primary, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              height: 30,
              width: 50,
            ),
            // const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                  color: ColorManager.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeLargeButton extends StatelessWidget {
  const HomeLargeButton({
    super.key,
    required this.title,
    required this.icon,
    required this.page,
  });
  final String title;
  final String icon;
  final String page;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed(page);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: ColorManager.background2,
          border: Border.all(color: ColorManager.primary, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              height: 50,
              width: 50,
              colorFilter:
                  const ColorFilter.mode(ColorManager.primary, BlendMode.srcIn),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                  color: ColorManager.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeWebButton extends StatelessWidget {
  const HomeWebButton({
    super.key,
    required this.url,
    required this.image,
  });
  final String url;
  final String image;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.WEB, parameters: {'url': url});
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        width: Get.width * 0.4,
        decoration: BoxDecoration(
          color: ColorManager.background2,
          border: Border.all(color: ColorManager.primary, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(
          image,
          height: 50,
          width: 50,
          colorFilter:
              const ColorFilter.mode(ColorManager.primary, BlendMode.srcIn),
        ),
      ),
    );
  }
}

class TopStoriesScreen extends StatelessWidget {
  final List<Map<String, String?>> topStories;

  const TopStoriesScreen(this.topStories, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: topStories.length,
      itemBuilder: (context, index) {
        final story = topStories[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (story['imageUrl'] != null && story['imageUrl']!.isNotEmpty)
                  Image.network(
                    story['imageUrl']!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image,
                          size: 100); // Placeholder icon
                    },
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(story['category']!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget buildLoadingContainer(int index, int activePage) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 400),
    width: Get.width * 0.5,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: index == activePage ? Colors.amber : ColorManager.lightGrey,
      borderRadius: BorderRadius.circular(12),
    ),
    alignment: index == activePage
        ? Alignment.center
        : index > activePage
            ? Alignment.centerLeft
            : Alignment.centerRight,
    child: showLoading(),
  );
}

Widget buildStoryContainer(
    Map<String, String?> story, int index, int activePage) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 400),
    width: Get.width * 0.6,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: index == activePage ? Colors.amber : ColorManager.lightGrey,
      borderRadius: BorderRadius.circular(12),
    ),
    alignment: index == activePage
        ? Alignment.center
        : index > activePage
            ? Alignment.centerLeft
            : Alignment.centerRight,
    child: Stack(
      children: [
        if (story['imageUrl'] != null && story['imageUrl']!.isNotEmpty)
          Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  story['imageUrl']!,
                  width: Get.width * 0.6,
                  height: 120,
                  fit: BoxFit.fitHeight,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image,
                        size: 100); // Placeholder icon
                  },
                ),
              ),
            ],
          ),
        Positioned(
          bottom: 0,
          child: buildStoryDetails(story, index, activePage),
        ),
      ],
    ),
  );
}

Widget buildStoryDetails(
    Map<String, String?> story, int index, int activePage) {
  return Container(
    padding: const EdgeInsets.all(8),
    width: Get.width * 0.6,
    height: activePage == index ? 120 : 100,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ColorManager.transparent,
          ColorManager.background2.withOpacity(.5),
          ColorManager.background1.withOpacity(.5),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    alignment: Alignment.bottomLeft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (activePage == index)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                story['category']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              InkWell(
                child: const Icon(
                  Icons.open_in_new_rounded,
                  color: ColorManager.black,
                  size: 18,
                ),
                onTap: () {
                  Get.toNamed(Routes.WEB,
                      parameters: {'url': story['link'].toString()});
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
        SizedBox(
          width: Get.width * 0.6,
          height: 80,
          child: Text(
            story['title']!,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
