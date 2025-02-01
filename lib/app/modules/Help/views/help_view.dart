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
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
            child: Form(
              key: formKey,
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
                            Get.offAndToNamed(Routes.HOME);
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          icon: SvgPicture.asset(
                            AssetsManager.about,
                            width: 32,
                          ),
                          onPressed: () {
                            Get.toNamed(Routes.ABOUT);
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
                    margin: const EdgeInsets.only(
                        left: 32, right: 32, top: 0, bottom: 32),
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
                        Text(
                            "Need help? Want to report a bug? Post an Ad? Request a feature? We're here to help!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: controller.themeController.theme
                                  .appBarTheme.titleTextStyle!.color,
                              fontSize: 14,
                            )),
                        Text(
                            "(this is not an official NUST app, I am just a student like you)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            )),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.nameController,
                          style: TextStyle(
                            color: controller.themeController.isDarkMode.value
                                ? ColorManager.white
                                : ColorManager.black,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Name (Optional)',
                            hintText: 'Enter your name',
                            hintStyle: TextStyle(color: ColorManager.lightGrey),
                            labelStyle:
                                TextStyle(color: ColorManager.lightGrey2),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: ColorManager.lightGrey2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.mailController,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Email is required'
                              : !GetUtils.isEmail(value)
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
                            labelStyle:
                                TextStyle(color: ColorManager.lightGrey2),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: ColorManager.lightGrey2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.messageController,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Message is required'
                              : null,
                          style: TextStyle(
                            color: controller.themeController.isDarkMode.value
                                ? ColorManager.white
                                : ColorManager.black,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            hintText: 'Enter your message',
                            hintStyle: TextStyle(color: ColorManager.lightGrey),
                            labelStyle:
                                TextStyle(color: ColorManager.lightGrey2),
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
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        controller.sendEmail();
                      }
                    },
                    margin: 32,
                  ),
                ],
              ),
            ),
          ),
        )));
  }
}
