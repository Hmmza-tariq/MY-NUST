import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nust/app/resources/assets_manager.dart';
import 'package:nust/app/routes/app_pages.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../resources/color_manager.dart';
import '../../widgets/home_widgets.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: controller.themeController.isDarkMode.value
              ? Colors.black
              : Colors.white,
          body: Container(
            decoration: BoxDecoration(
              gradient: (controller.themeController.isDarkMode.value)
                  ? RadialGradient(
                      center: Alignment.center,
                      radius: .6,
                      colors: [
                          ColorManager.darkPrimary.withOpacity(.4),
                          ColorManager.darkGrey.withOpacity(.4),
                        ])
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ColorManager.secondary.withOpacity(.2),
                        ColorManager.primary.withOpacity(.2),
                      ],
                    ),
            ),
            alignment: Alignment.center,
            height: Get.height,
            child: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                Get.toNamed(Routes.WEB, parameters: {
                                  'url':
                                      '${controller.campusController.getCampusUrl()}/downloads'
                                });
                              },
                              icon: SvgPicture.asset(
                                AssetsManager.download,
                                width: 40,
                                colorFilter: ColorFilter.mode(
                                    controller.themeController.isDarkMode.value
                                        ? ColorManager.lightGrey1
                                        : ColorManager.darkPrimary,
                                    BlendMode.srcIn),
                              )),
                          const HomeCampusWidget(),
                          IconButton(
                              onPressed: controller.fetchStories,
                              icon: SvgPicture.asset(
                                AssetsManager.refresh,
                                width: 40,
                                colorFilter: ColorFilter.mode(
                                    controller.themeController.isDarkMode.value
                                        ? ColorManager.lightGrey1
                                        : ColorManager.darkPrimary,
                                    BlendMode.srcIn),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HomeCampusButton(
                          isAsset: true,
                          image: AssetsManager.nustLogo,
                          url: controller.campusController.baseUrl,
                        ),
                        SizedBox(width: Get.width * 0.04),
                        HomeCampusButton(
                          isAsset: false,
                          image: controller.campusController.logo.value,
                          url: controller.campusController.getCampusUrl(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      final isLoading = controller.isLoading.value;
                      final isError = controller.isError.value;
                      final activePage = controller.activePage.value;
                      final topStories =
                          controller.campusController.topStories.value;

                      return SizedBox(
                        height: 240,
                        child: CarouselSlider.builder(
                          controller: controller.pageController,
                          options: CarouselOptions(
                            height: 240,
                            enableInfiniteScroll: true,
                            enlargeCenterPage: true,
                            autoPlay: true,
                            viewportFraction: 0.6,
                            onPageChanged: (index, reason) {
                              controller.activePage.value = index;
                            },
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 1500),
                            autoPlayInterval: const Duration(seconds: 5),
                            scrollPhysics: const BouncingScrollPhysics(),
                          ),
                          itemCount:
                              (isError || isLoading) ? 3 : topStories.length,
                          itemBuilder: (context, index, realIndex) {
                            if (!controller.internetController.isOnline.value) {
                              return Center(
                                child: BuildNoInternetContainer(
                                    index: index, activePage: activePage),
                              );
                            } else if (isLoading || isError) {
                              return Center(
                                child: BuildLoadingContainer(
                                    index: index, activePage: activePage),
                              );
                            } else {
                              final story = topStories[index];
                              return BuildStoryContainer(
                                  isLast: index == topStories.length - 1,
                                  story: story,
                                  index: index,
                                  activePage: activePage);
                            }
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      return AnimatedSmoothIndicator(
                        activeIndex: controller.activePage.value,
                        count: (controller.isLoading.value ||
                                controller.isError.value)
                            ? 3
                            : controller
                                .campusController.topStories.value.length,
                        onDotClicked: (index) {
                          controller.pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        effect: CustomizableEffect(
                          activeDotDecoration: DotDecoration(
                            width: 12,
                            height: 12,
                            color: ColorManager.primary,
                            dotBorder: const DotBorder(
                              padding: 2,
                              width: 2,
                              color: ColorManager.primary,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          dotDecoration: DotDecoration(
                            rotationAngle: 45,
                            color: Colors.grey,
                            dotBorder: const DotBorder(
                              padding: 2,
                              width: 2,
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          spacing: 6.0,
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: Get.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HomeWebButton(
                            image: AssetsManager.lms,
                            url: controller.lmsUrl,
                          ),
                          SizedBox(width: Get.width * 0.04),
                          HomeWebButton(
                            image: AssetsManager.qalam,
                            url: controller.qalamUrl,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const HomeLargeButton(
                      title: 'Calculate GPA',
                      icon: AssetsManager.gpa,
                      page: Routes.GPA_CALCULATION,
                    ),
                    const SizedBox(height: 16),
                    const HomeLargeButton(
                      title: 'Calculate Absolutes',
                      icon: AssetsManager.result,
                      page: Routes.ABSOLUTES_CALCULATION,
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        HomeSmallButton(
                          title: 'Settings',
                          icon: AssetsManager.settings,
                          page: Routes.SETTINGS,
                        ),
                        HomeSmallButton(
                          title: 'Help',
                          icon: AssetsManager.help,
                          page: Routes.HELP,
                        ),
                        HomeSmallButton(
                          title: 'About',
                          icon: AssetsManager.about,
                          page: Routes.ABOUT,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
