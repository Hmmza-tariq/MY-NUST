import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:nust/app/modules/widgets/custom_button.dart';
import 'package:nust/app/resources/assets_manager.dart';
import 'package:nust/app/resources/color_manager.dart';

import '../../../routes/app_pages.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        backgroundColor:
            controller.themeController.theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: ColorManager.gradientColor,
            ),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                height: Get.height,
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
                            AssetsManager.help,
                            width: 32,
                          ),
                          onPressed: () {
                            Get.toNamed(Routes.HELP);
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
                          Text('Settings',
                              style: TextStyle(
                                  color: controller.themeController.theme
                                      .appBarTheme.titleTextStyle!.color,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                          Center(
                            child: Image.asset(AssetsManager.settingsBanner,
                                height: Get.height * 0.33),
                          ),
                          SettingSwitchButton(
                            title: 'Dark Mode',
                            subTitle: 'Toggle the app\'s theme',
                            isSwitched: controller.themeController.isDarkMode,
                            onChanged: controller.themeController.toggleTheme,
                          ),
                          const SizedBox(height: 20),
                          SettingSwitchButton(
                            title: 'Biometric Authentication',
                            subTitle: controller
                                    .authenticationController.supportState.value
                                ? 'Secure your account with biometric authentication'
                                : 'Biometric authentication is not supported on this device',
                            isSwitched: controller
                                    .authenticationController.supportState.value
                                ? controller
                                    .authenticationController.isBiometricEnabled
                                : false.obs,
                            onChanged: controller
                                    .authenticationController.supportState.value
                                ? controller
                                    .authenticationController.toggleBiometric
                                : null,
                          ),
                          const SizedBox(height: 20),
                          SettingSwitchButton(
                            title: 'Autofill ID / Password',
                            subTitle:
                                'Automatically fill Credential fields of LMS and QALAM',
                            isSwitched: controller
                                .authenticationController.isAutofillEnabled,
                            onChanged: (bool value) {
                              if (value) {
                                TextEditingController idController =
                                    TextEditingController(
                                        text: controller
                                            .authenticationController.id.value);
                                TextEditingController lmsPasswordController =
                                    TextEditingController(
                                        text: controller
                                            .authenticationController
                                            .lmsPassword
                                            .value);
                                TextEditingController qalamPasswordController =
                                    TextEditingController(
                                        text: controller
                                            .authenticationController
                                            .qalamPassword
                                            .value);
                                Get.defaultDialog(
                                  title: 'Add Credentials',
                                  titleStyle: TextStyle(
                                      color: controller.themeController.theme
                                          .appBarTheme.titleTextStyle!.color),
                                  backgroundColor: controller.themeController
                                      .theme.scaffoldBackgroundColor,
                                  content: Column(
                                    children: [
                                      TextField(
                                        controller: idController,
                                        style: TextStyle(
                                            color: controller
                                                .themeController
                                                .theme
                                                .appBarTheme
                                                .titleTextStyle!
                                                .color),
                                        decoration: InputDecoration(
                                          labelText: 'ID',
                                          labelStyle: TextStyle(
                                              color: controller
                                                  .themeController
                                                  .theme
                                                  .appBarTheme
                                                  .titleTextStyle!
                                                  .color),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: controller
                                                    .themeController
                                                    .theme
                                                    .appBarTheme
                                                    .titleTextStyle!
                                                    .color!),
                                          ),
                                        ),
                                      ),
                                      TextField(
                                        controller: lmsPasswordController,
                                        style: TextStyle(
                                            color: controller
                                                .themeController
                                                .theme
                                                .appBarTheme
                                                .titleTextStyle!
                                                .color),
                                        decoration: InputDecoration(
                                          labelText: 'LMS Password',
                                          labelStyle: TextStyle(
                                              color: controller
                                                  .themeController
                                                  .theme
                                                  .appBarTheme
                                                  .titleTextStyle!
                                                  .color),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: controller
                                                    .themeController
                                                    .theme
                                                    .appBarTheme
                                                    .titleTextStyle!
                                                    .color!),
                                          ),
                                        ),
                                      ),
                                      TextField(
                                        controller: qalamPasswordController,
                                        style: TextStyle(
                                            color: controller
                                                .themeController
                                                .theme
                                                .appBarTheme
                                                .titleTextStyle!
                                                .color),
                                        decoration: InputDecoration(
                                          labelText: 'QALAM Password',
                                          labelStyle: TextStyle(
                                              color: controller
                                                  .themeController
                                                  .theme
                                                  .appBarTheme
                                                  .titleTextStyle!
                                                  .color),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: controller
                                                    .themeController
                                                    .theme
                                                    .appBarTheme
                                                    .titleTextStyle!
                                                    .color!),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  confirm: CustomButton(
                                      title: 'Save',
                                      color: ColorManager.primary,
                                      textColor: ColorManager.background2,
                                      widthFactor: 1,
                                      onPressed: () {
                                        controller.authenticationController
                                            .setCredentials(
                                                idController.text,
                                                lmsPasswordController.text,
                                                qalamPasswordController.text);
                                        controller.authenticationController
                                            .isAutofillEnabled.value = true;
                                        Get.back();
                                      }),
                                  cancel: CustomButton(
                                      title: 'Cancel',
                                      color: controller.themeController.theme
                                          .cardTheme.color!,
                                      textColor: controller
                                          .themeController
                                          .theme
                                          .appBarTheme
                                          .titleTextStyle!
                                          .color!,
                                      widthFactor: 1,
                                      onPressed: () {
                                        Get.back();
                                      }),
                                );
                              } else {
                                controller.authenticationController
                                    .isAutofillEnabled.value = false;
                              }
                            },
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: CustomButton(
                        title: 'Reset Settings',
                        color: ColorManager.primary,
                        textColor: Colors.white,
                        widthFactor: 1,
                        onPressed: () => Get.defaultDialog(
                          contentPadding: const EdgeInsets.all(16),
                          title: 'Reset Settings',
                          titleStyle: TextStyle(
                              color: controller.themeController.theme
                                  .appBarTheme.titleTextStyle!.color),
                          backgroundColor: controller
                              .themeController.theme.scaffoldBackgroundColor,
                          content: Text.rich(
                            TextSpan(
                              text:
                                  'Are you sure you want to reset all settings?',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: controller.themeController.theme
                                      .appBarTheme.titleTextStyle!.color),
                              children: const [
                                TextSpan(
                                    text: '\nThis action cannot be undone.',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: ColorManager.error))
                              ],
                            ),
                          ),
                          confirm: CustomButton(
                              title: 'Reset',
                              color: ColorManager.primary,
                              textColor: ColorManager.background2,
                              widthFactor: 1,
                              onPressed: () {
                                controller.resetSettings();
                                Get.back();
                              }),
                          cancel: CustomButton(
                              title: 'Cancel',
                              color: controller
                                  .themeController.theme.cardTheme.color!,
                              textColor: controller.themeController.theme
                                  .appBarTheme.titleTextStyle!.color!,
                              widthFactor: 1,
                              onPressed: () {
                                Get.back();
                              }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )));
  }
}

class SettingSwitchButton extends StatelessWidget {
  const SettingSwitchButton({
    super.key,
    required this.title,
    required this.subTitle,
    required this.isSwitched,
    this.onChanged,
  });

  final String title;
  final String subTitle;
  final RxBool isSwitched;
  final void Function(bool)? onChanged;
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: controller.themeController.theme.appBarTheme
                              .titleTextStyle!.color,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 0.5,
                        child: Text(
                          subTitle,
                          style: TextStyle(
                            fontSize: 10,
                            color: controller.themeController.theme.appBarTheme
                                .titleTextStyle!.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isSwitched.value,
                    onChanged: onChanged,
                    activeColor: ColorManager.primary,
                    inactiveThumbColor: ColorManager.lightGrey2,
                    inactiveTrackColor: ColorManager.lightGrey1,
                  )
                ],
              ),
              const Divider(
                color: ColorManager.lightGrey1,
                thickness: 1,
              ),
            ],
          )),
    );
  }
}
