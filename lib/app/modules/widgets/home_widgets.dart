import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nust/app/controllers/theme_controller.dart';
import 'package:nust/app/data/entities/lines.dart';
import 'package:nust/app/modules/widgets/error_widget.dart';
import 'package:nust/app/resources/assets_manager.dart';
import 'package:nust/app/resources/color_manager.dart';
import 'package:nust/app/routes/app_pages.dart';
import '../home/controllers/home_controller.dart';
import 'custom_button.dart';
import 'loading.dart';

class HomeCampusWidget extends StatelessWidget {
  const HomeCampusWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    return Obx(() => ElevatedButton(
          style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: ColorManager.transparent,
              shadowColor: ColorManager.primary.withOpacity(.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: ColorManager.darkPrimary.withOpacity(.8), width: 2),
              ),
              fixedSize: Size.fromWidth(Get.width * .46),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8)),
          child: Text(
              "${controller.campusController.selectedCampus.value} Campus",
              style: TextStyle(
                  fontSize: 18,
                  color: controller.themeController.isDarkMode.value
                      ? ColorManager.white
                      : ColorManager.black,
                  fontWeight: FontWeight.bold)),
          onPressed: () => Get.defaultDialog(
            title: 'Select Campus',
            titleStyle: TextStyle(
              color: controller
                  .themeController.theme.appBarTheme.titleTextStyle!.color,
            ),
            backgroundColor:
                controller.themeController.theme.scaffoldBackgroundColor,
            content: SizedBox(
              height: Get.height * 0.4,
              width: Get.width * 0.9,
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: Get.width * .005,
                ),
                shrinkWrap: true,
                // physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...controller.campusController.campuses.map((campus) =>
                      CustomButton(
                          isBold: false,
                          title: campus,
                          onPressed: () {
                            controller.campusController.setCampus(campus);
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
            width: Get.width * 0.46,
            decoration: BoxDecoration(
              // color: themeController.isDarkMode.value
              //     ? ColorManager.lightGrey2
              //     : ColorManager.lightGrey,
              gradient: ColorManager.gradientColor,
              border: Border.all(
                  color: ColorManager.darkPrimary.withOpacity(.2), width: 2),
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

class BuildLoadingContainer extends StatelessWidget {
  const BuildLoadingContainer({
    super.key,
    required this.index,
    required this.activePage,
  });
  final int index;
  final int activePage;

  @override
  Widget build(BuildContext context) {
    return HomeSliderItem(
      index: index,
      activePage: activePage,
      child: heightLoading((Get.height * .2).clamp(80, 100)),
    );
  }
}

class BuildNoInternetContainer extends StatelessWidget {
  const BuildNoInternetContainer({
    super.key,
    required this.index,
    required this.activePage,
  });
  final int index;
  final int activePage;

  @override
  Widget build(BuildContext context) {
    return HomeSliderItem(
      index: index,
      activePage: activePage,
      child: ErrorScreen(
        roundedBorder: true,
        details: "No Internet Connection",
        height: (Get.height * .2).clamp(80, 100),
        width: Get.width * 0.6,
      ),
    );
  }
}

class BuildStoryContainer extends StatelessWidget {
  const BuildStoryContainer({
    super.key,
    required this.story,
    required this.index,
    required this.activePage,
    required this.isLast,
  });
  final Map<String, String?> story;
  final int index;
  final int activePage;
  final bool isLast;
  @override
  Widget build(BuildContext context) {
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
      child: isLast
          ? Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  width: Get.width * 0.6,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    color: activePage == index
                        ? ColorManager.primaryDark
                        : ColorManager.transparent,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        AssetsManager.logo,
                        width: Get.width * 0.25,
                        fit: BoxFit.fitHeight,
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.close_rounded,
                        color: ColorManager.white,
                        size: 10,
                      ),
                      const Spacer(),
                      Image.asset(
                        AssetsManager.hexagone,
                        width: Get.width * 0.25,
                        fit: BoxFit.fitHeight,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  width: Get.width * 0.58,
                  height: activePage == index ? 110 : 60,
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
                    children: [
                      Text.rich(
                        TextSpan(
                          text: "My NUST",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            const TextSpan(
                              text: " a one stop solution for NUSTians! ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: (activePage == index)
                                  ? "Want to post something?"
                                  : "",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      (activePage == index)
                          ? TextButton(
                              style: TextButton.styleFrom(
                                  shape: BeveledRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  foregroundColor: ColorManager.black),
                              onPressed: () => Get.toNamed(Routes.HELP),
                              child: const Text(
                                "Contact us",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ],
            )
          : Stack(
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
                            width: Get.width,
                            height: 120,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => showLoading(),
                            errorWidget: (context, url, error) =>
                                HomeSliderItem(
                                  index: index,
                                  activePage: activePage,
                                  child: ErrorScreen(
                                    roundedBorder: true,
                                    details: "",
                                    height: Get.height * .1,
                                    width: Get.width * 0.6,
                                  ),
                                )),
                      ),
                    ],
                  ),
                Positioned(
                  bottom: 0,
                  child: BuildStoryDetails(
                      story: story, index: index, activePage: activePage),
                ),
              ],
            ),
    );
  }
}

class HomeSliderItem extends StatelessWidget {
  const HomeSliderItem({
    super.key,
    required this.index,
    required this.activePage,
    required this.child,
  });

  final int index;
  final int activePage;
  final Widget child;
  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: [
          child,
          SizedBox(
              width: Get.width * 0.6,
              height: index != activePage ? 50 : 80,
              child: Text.rich(
                TextSpan(
                  text: index != activePage ? "" : 'Random fact:\n',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColorManager.black,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: lines[Random().nextInt(lines.length)],
                      style: TextStyle(
                        fontSize: index != activePage ? 10 : 14,
                        color: ColorManager.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class BuildStoryDetails extends StatelessWidget {
  const BuildStoryDetails({
    super.key,
    required this.story,
    required this.index,
    required this.activePage,
  });
  final Map<String, String?> story;
  final int index;
  final int activePage;

  @override
  Widget build(BuildContext context) {
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
      debugPrint('Error parsing campus: $e');
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
            width: Get.width * 0.46,
            decoration: BoxDecoration(
              color: themeController.theme.cardTheme.color,
              border: Border.all(
                  color: themeController.isDarkMode.value
                      ? ColorManager.lightPrimary.withOpacity(.2)
                      : ColorManager.darkPrimary.withOpacity(.4),
                  width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(
              image,
              height: 50,
              width: 50,
              colorFilter: ColorFilter.mode(
                  themeController.isDarkMode.value
                      ? ColorManager.lightPrimary
                      : ColorManager.darkPrimary,
                  BlendMode.srcIn),
            ),
          )),
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
            width: Get.width * 0.96,
            decoration: BoxDecoration(
              color: themeController.theme.cardTheme.color,
              border: Border.all(
                  color: themeController.isDarkMode.value
                      ? ColorManager.lightPrimary.withOpacity(.2)
                      : ColorManager.darkPrimary.withOpacity(.4),
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
                          ? ColorManager.lightPrimary
                          : ColorManager.darkPrimary,
                      BlendMode.srcIn),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? ColorManager.lightPrimary
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
            width: Get.width * 0.31,
            height: 70,
            // margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: themeController.theme.cardTheme.color,
              border: Border.all(
                  color: themeController.isDarkMode.value
                      ? ColorManager.lightPrimary.withOpacity(.2)
                      : ColorManager.darkPrimary.withOpacity(.4),
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
                          ? ColorManager.lightPrimary
                          : ColorManager.darkPrimary,
                      BlendMode.srcIn),
                ),
                // const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                      color: themeController.isDarkMode.value
                          ? ColorManager.lightPrimary
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
