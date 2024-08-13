import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
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
          backgroundColor:
              controller.themeController.theme.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            InkWell(
                                onTap: () => Get.toNamed(Routes.WEB,
                                        parameters: {
                                          'url': 'https://nust.edu.pk/'
                                        }),
                                child:
                                    Image.asset(AssetsManager.logo, width: 32)),
                            const Spacer(),
                            const HomeCampusWidget(),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: ColorManager.primary,
                              ),
                              onPressed: () {
                                controller.fetchStories();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(() {
                        final isLoading = controller.isLoading.value;
                        final activePage = controller.activePage.value;
                        final topStories = controller.topStories.value;

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
                              scrollPhysics: const BouncingScrollPhysics(),
                            ),
                            itemCount: isLoading ? 3 : topStories.length,
                            itemBuilder: (context, index, realIndex) {
                              if (isLoading) {
                                return Center(
                                  child:
                                      buildLoadingContainer(index, activePage),
                                );
                              }

                              final story = topStories[index];
                              return buildStoryContainer(
                                  story, index, activePage);
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      Obx(
                        () => AnimatedSmoothIndicator(
                          activeIndex: controller.activePage.value,
                          count: controller.isLoading.value
                              ? 3
                              : controller.topStories.value.length,
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: Get.width * 0.9,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HomeWebButton(
                          image: AssetsManager.lms,
                          url: 'https://lms.nust.edu.pk/portal/my/',
                        ),
                        HomeWebButton(
                          image: AssetsManager.qalam,
                          url: 'https://qalam.nust.edu.pk/student/profile',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const HomeLargeButton(
                    title: 'Calculate GPA',
                    icon: AssetsManager.gpa,
                    page: Routes.GPA_CALCULATION,
                  ),
                  const SizedBox(height: 20),
                  const HomeLargeButton(
                    title: 'Calculate Aggregate',
                    icon: AssetsManager.result,
                    page: Routes.GPA_CALCULATION,
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ));
  }
}
