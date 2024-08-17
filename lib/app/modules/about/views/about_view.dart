import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:nust/app/resources/color_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../resources/assets_manager.dart';
import '../../../routes/app_pages.dart';
import '../../widgets/custom_button.dart';
import '../controllers/about_controller.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        backgroundColor:
            controller.themeController.theme.scaffoldBackgroundColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: ColorManager.gradientColor,
          ),
          height: Get.height,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SafeArea(
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: ColorManager.primary,
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      const Spacer(),
                      IconButton(
                        icon: SvgPicture.asset(
                          AssetsManager.settings,
                          width: 32,
                        ),
                        onPressed: () {
                          Get.toNamed(Routes.SETTINGS);
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: controller.themeController.theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('About',
                          style: TextStyle(
                              color: controller.themeController.theme
                                  .appBarTheme.titleTextStyle!.color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      Center(
                          child: Image.asset(AssetsManager.aboutBanner,
                              height: Get.height * 0.33)),
                      Text(
                        'Author Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: controller.themeController.isDarkMode.value
                              ? ColorManager.white
                              : ColorManager.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Hey, I'm Hamza. Have a nice day! :)",
                        style: TextStyle(
                          fontSize: 14,
                          color: controller.themeController.isDarkMode.value
                              ? ColorManager.white
                              : ColorManager.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(color: ColorManager.lightGrey),
                      Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: controller.themeController.isDarkMode.value
                              ? ColorManager.white
                              : ColorManager.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'We take your privacy seriously. This app does not collect any personal data or information from its users. Any data you enter in the app, such as LMS / Qalam ID, Passwords or your GPA, is stored locally on your device and not shared with any third parties.',
                        style: TextStyle(
                          fontSize: 14,
                          color: controller.themeController.isDarkMode.value
                              ? ColorManager.white
                              : ColorManager.black,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      Text(
                        'By using this app, you agree to the following:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: controller.themeController.isDarkMode.value
                              ? ColorManager.white
                              : ColorManager.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '- All data you enter in the app is stored locally on your device and is not shared with any external servers.',
                        style: TextStyle(
                          fontSize: 14,
                          color: controller.themeController.isDarkMode.value
                              ? ColorManager.white
                              : ColorManager.black,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      Text(
                        '- We do not collect or store any personal information, including your name, email, or location.',
                        style: TextStyle(
                          fontSize: 14,
                          color: controller.themeController.isDarkMode.value
                              ? ColorManager.white
                              : ColorManager.black,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const Divider(color: ColorManager.lightGrey),
                      Row(
                        children: [
                          Text(
                            'For more details visit:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: controller.themeController.isDarkMode.value
                                  ? ColorManager.white
                                  : ColorManager.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              launchUrl(Uri.parse(
                                  "https://sites.google.com/view/my-nust-terms-and-conditions/home"));
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.link_rounded,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              launchUrl(Uri.parse(
                                  "https://sites.google.com/view/my-nust-terms-and-conditions/home"));
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.link_rounded,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Terms and Conditions',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: ColorManager.lightGrey),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request source code:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: controller
                                          .themeController.isDarkMode.value
                                      ? ColorManager.white
                                      : ColorManager.black,
                                ),
                              ),
                              Text(
                                '(not going to approve it though)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: controller
                                          .themeController.isDarkMode.value
                                      ? ColorManager.white
                                      : ColorManager.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              launchUrl(Uri.parse(
                                  "https://github.com/Hmmza-tariq/My-NUST-request-"));
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.open_in_new_rounded,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Github',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomButton(
                    title: 'Share App',
                    color: ColorManager.primary,
                    textColor: ColorManager.background2,
                    widthFactor: 1,
                    margin: 32,
                    onPressed: () {
                      Share.share(
                        'Check out this cool NUST App available on PlayStore!🔥 \nDownload now: https://play.google.com/store/apps/details?id=com.hexagone.mynust&pcampaignid=web_share',
                      );
                    }),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                          title: 'Play Store',
                          color: ColorManager.primary,
                          textColor: ColorManager.background2,
                          widthFactor: .4,
                          onPressed: () {
                            launchUrl(Uri.parse(
                                "https://play.google.com/store/apps/details?id=com.hexagone.mynust&pcampaignid=web_share"));
                          }),
                      CustomButton(
                          title: 'App Store',
                          color: ColorManager.primary,
                          textColor: ColorManager.background2,
                          widthFactor: .4,
                          onPressed: () {
                            launchUrl(Uri.parse(
                                "https://apps.apple.com/us/app/my-nust/id1580134134"));
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )));
  }
}
