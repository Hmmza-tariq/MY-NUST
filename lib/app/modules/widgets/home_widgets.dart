import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/theme_controller.dart';
import 'package:nust/app/modules/widgets/error_widget.dart';
import 'package:nust/app/resources/assets_manager.dart';
import 'package:nust/app/resources/color_manager.dart';
import 'package:nust/app/routes/app_pages.dart';

import '../home/controllers/home_controller.dart';
import 'custom_button.dart';
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
    final ThemeController themeController = Get.find();
    return InkWell(
      onTap: () {
        Get.toNamed(page);
      },
      child: Obx(
        () => Container(
            width: Get.width * 0.23,
            height: 70,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: themeController.theme.cardTheme.color,
              border: Border.all(
                  color: themeController.isDarkMode.value
                      ? ColorManager.lightestPrimary
                      : ColorManager.darkPrimary,
                  width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  icon,
                  height: 30,
                  width: 50,
                  colorFilter: ColorFilter.mode(
                      themeController.isDarkMode.value
                          ? ColorManager.lightestPrimary
                          : ColorManager.darkPrimary,
                      BlendMode.srcIn),
                ),
                // const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? ColorManager.lightestPrimary
                          : ColorManager.darkPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )),
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
    final ThemeController themeController = Get.find();
    return InkWell(
      onTap: () {
        Get.toNamed(page);
      },
      child: Obx(() => Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: themeController.theme.cardTheme.color,
              border: Border.all(
                  color: themeController.isDarkMode.value
                      ? ColorManager.lightestPrimary
                      : ColorManager.darkPrimary,
                  width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  icon,
                  height: 50,
                  width: 50,
                  colorFilter: ColorFilter.mode(
                      themeController.isDarkMode.value
                          ? ColorManager.lightestPrimary
                          : ColorManager.darkPrimary,
                      BlendMode.srcIn),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? ColorManager.lightestPrimary
                          : ColorManager.darkPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
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
    final ThemeController themeController = Get.find();
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.WEB, parameters: {'url': url});
      },
      child: Obx(() => Container(
            padding: const EdgeInsets.all(10),
            width: Get.width * 0.44,
            decoration: BoxDecoration(
              color: themeController.theme.cardTheme.color,
              border: Border.all(
                  color: themeController.isDarkMode.value
                      ? ColorManager.lightestPrimary
                      : ColorManager.darkPrimary,
                  width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(
              image,
              height: 50,
              width: 50,
              colorFilter: ColorFilter.mode(
                  themeController.isDarkMode.value
                      ? ColorManager.lightestPrimary
                      : ColorManager.darkPrimary,
                  BlendMode.srcIn),
            ),
          )),
    );
  }
}

class HomeCampusButton extends StatelessWidget {
  const HomeCampusButton({
    super.key,
    required this.url,
    required this.image,
    required this.isAsset,
  });
  final String url;
  final String image;
  final bool isAsset;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    final HomeController controller = Get.find();
    return Obx(
      () => InkWell(
          onTap: () {
            if (!controller.isLoading.value) {
              Get.toNamed(Routes.WEB, parameters: {'url': url});
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            width: Get.width * 0.44,
            decoration: BoxDecoration(
              // color: themeController.isDarkMode.value
              //     ? ColorManager.lightGrey2
              //     : ColorManager.lightGrey,
              gradient: ColorManager.gradientColor,
              border: Border.all(color: ColorManager.primary, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: controller.isLoading.value
                ? SizedBox(height: 50, width: 50, child: showLoading())
                : isAsset
                    ? Image.asset(
                        image,
                        height: 50,
                        width: 50,
                        color: themeController.isDarkMode.value
                            ? ColorManager.white
                            : null,
                      )
                    : CachedNetworkImage(
                        imageUrl: image,
                        height: 50,
                        width: 50,
                        placeholder: (context, url) => SizedBox(
                          height: 50,
                          width: 50,
                          child: showLoading(),
                        ),
                        errorWidget: (context, url, error) => SizedBox(
                          height: 50,
                          width: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AssetsManager.transparentLogo,
                                height: 40,
                                width: 40,
                                color: themeController.isDarkMode.value
                                    ? ColorManager.white
                                    : null,
                              ),
                              const SizedBox(width: 5),
                              SizedBox(
                                width: 50,
                                child: Text(
                                    controller
                                        .campusController.selectedCampus.value,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: themeController.isDarkMode.value
                                            ? ColorManager.white
                                            : ColorManager.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
          )),
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
  String imageUrl = story['imageUrl'] ?? '';

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
        if (imageUrl != '')
          Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                    imageUrl: story['imageUrl']!,
                    width: Get.width * 0.6,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => showLoading(),
                    errorWidget: (context, url, error) => ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: ErrorScreen(
                            details: "",
                            height: 120,
                            width: Get.width * 0.6,
                          ),
                        )),
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
  String category = story['category'] ?? '';
  String title = story['title'] ?? '';
  String link = story['link'] ?? '';

  String campus = '';
  try {
    campus = link
        .split(".edu")[0]
        .replaceAll("https://", "")
        .replaceAll(".", " ")
        .toUpperCase();
  } catch (e) {
    campus = '';
  }
  category = category == '' ? 'Top $campus Stories' : category;

  return Container(
    padding: const EdgeInsets.all(8),
    width: Get.width * 0.58,
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
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
    ),
    alignment: Alignment.bottomCenter,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (activePage == index)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (link != '')
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
            title,
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

class HomeCampusWidget extends StatelessWidget {
  const HomeCampusWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    return Obx(() => CustomButton(
          title: '${controller.campusController.selectedCampus.value} Campus',
          color: controller.themeController.theme.scaffoldBackgroundColor,
          textColor: controller.themeController.isDarkMode.value
              ? ColorManager.white
              : ColorManager.black,
          widthFactor: .46,
          onPressed: () => Get.defaultDialog(
            title: 'Select Campus',
            titleStyle: TextStyle(
              color: controller
                  .themeController.theme.appBarTheme.titleTextStyle!.color,
            ),
            backgroundColor:
                controller.themeController.theme.scaffoldBackgroundColor,
            content: SizedBox(
              height:
                  (controller.campusController.campuses.length / 3).round() *
                      (80),
              width: Get.width * 0.9,
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...controller.campusController.campuses.map((campus) =>
                      CustomButton(
                          isBold: false,
                          title: campus,
                          onPressed: () {
                            controller.campusController.selectedCampus.value =
                                campus;
                            controller.fetchStories();
                            Get.back();
                          },
                          color: campus ==
                                  controller
                                      .campusController.selectedCampus.value
                              ? ColorManager.primary
                              : controller
                                  .themeController.theme.cardTheme.color!,
                          textColor: campus ==
                                  controller
                                      .campusController.selectedCampus.value
                              ? ColorManager.white
                              : controller.themeController.theme.appBarTheme
                                  .titleTextStyle!.color!,
                          widthFactor: .2)),
                ],
              ),
            ),
          ),
        ));
  }
}
