import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../resources/assets_manager.dart';
import '../../../resources/color_manager.dart';
import '../../../routes/app_pages.dart';
import '../../widgets/custom_button.dart';
import '../controllers/help_controller.dart';

class HelpView extends GetView<HelpController> {
  const HelpView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        backgroundColor:
            controller.themeController.theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SafeArea(
            child: Column(
              children: [
                Row(
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
                        AssetsManager.about_bg1,
                        width: 32,
                      ),
                      onPressed: () {
                        Get.toNamed(Routes.ABOUT);
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
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
                      Text('Help',
                          style: TextStyle(
                              color: controller.themeController.theme
                                  .appBarTheme.titleTextStyle!.color,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      Center(
                          child: Image.asset(AssetsManager.helpBanner,
                              height: Get.height * 0.33)),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: TextStyle(
                          color: controller.themeController.isDarkMode.value
                              ? ColorManager.white
                              : ColorManager.black,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Name (Optional)',
                          hintText: 'Enter your name',
                          hintStyle: TextStyle(color: ColorManager.lightGrey),
                          labelStyle: TextStyle(color: ColorManager.lightGrey2),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: ColorManager.lightGrey2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (value) =>
                            !GetUtils.isEmail(value.toString())
                                ? 'Enter a valid email'
                                : null,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          color: controller.themeController.isDarkMode.value
                              ? ColorManager.white
                              : ColorManager.black,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: ColorManager.lightGrey),
                          labelStyle: TextStyle(color: ColorManager.lightGrey2),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: ColorManager.lightGrey2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: TextStyle(
                          color: controller.themeController.isDarkMode.value
                              ? ColorManager.white
                              : ColorManager.black,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          hintText: 'Enter your message',
                          hintStyle: TextStyle(color: ColorManager.lightGrey),
                          labelStyle: TextStyle(color: ColorManager.lightGrey2),
                          prefixIcon: Icon(
                            Icons.message_outlined,
                            color: ColorManager.lightGrey2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  title: 'Send',
                  color: ColorManager.primary,
                  textColor: ColorManager.background2,
                  widthFactor: 1,
                  onPressed: controller.sendEmail,
                  margin: 32,
                ),
              ],
            ),
          ),
        )));
  }
}
