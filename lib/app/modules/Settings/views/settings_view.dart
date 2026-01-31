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
                          Get.offAndToNamed(Routes.HOME);
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
                            addCredentials(controller);
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
                          color: controller.themeController.theme.appBarTheme
                              .titleTextStyle!.color),
                      backgroundColor: controller
                          .themeController.theme.scaffoldBackgroundColor,
                      content: Text.rich(
                        TextSpan(
                          text: 'Are you sure you want to reset all settings?',
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
                          color:
                              controller.themeController.theme.cardTheme.color!,
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
                  Expanded(
                    child: Column(
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
                        Text(
                          subTitle,
                          style: TextStyle(
                            fontSize: 10,
                            color: controller.themeController.theme.appBarTheme
                                .titleTextStyle!.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: isSwitched.value,
                    onChanged: onChanged,
                    activeThumbColor: ColorManager.primary,
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

void addCredentials(SettingsController controller) {
  TextEditingController idController =
      TextEditingController(text: controller.authenticationController.id.value);
  TextEditingController lmsPasswordController = TextEditingController(
      text: controller.authenticationController.lmsPassword.value);
  TextEditingController qalamPasswordController = TextEditingController(
      text: controller.authenticationController.qalamPassword.value);
  RxBool isReadInfo = false.obs;
  RxBool showLMSPass = false.obs;
  RxBool showQalamPass = false.obs;
  Get.dialog(Dialog(
    backgroundColor: controller.themeController.theme.scaffoldBackgroundColor,
    child: Obx(() => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                        isReadInfo.value == true
                            ? 'Why do we need your credentials?'
                            : 'Add Credentials',
                        style: TextStyle(
                            color: controller.themeController.theme.appBarTheme
                                .titleTextStyle!.color,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                        isReadInfo.value == false
                            ? Icons.info_outline
                            : Icons.cancel_outlined,
                        color: controller.themeController.theme.appBarTheme
                            .titleTextStyle!.color),
                    onPressed: () {
                      isReadInfo.value = !isReadInfo.value;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              isReadInfo.value == true
                  ? Column(
                      children: [
                        Text(
                            'We need your credentials to autofill the login fields of LMS and QALAM. Your credentials are stored securely on your device and are not shared with anyone.',
                            style: TextStyle(
                                color: controller.themeController.theme
                                    .appBarTheme.titleTextStyle!.color,
                                fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                            'We take your data security seriously. However, please be aware that any issues related to this data are beyond our control. It is your responsibility to keep your device secure and ensure the safety of your login credentials.',
                            style: TextStyle(
                                color: controller.themeController.theme
                                    .appBarTheme.titleTextStyle!.color,
                                fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                            'If you are not comfortable with this, you can disable this feature at any time.',
                            style: TextStyle(
                                color: controller.themeController.theme
                                    .appBarTheme.titleTextStyle!.color,
                                fontSize: 14)),
                      ],
                    )
                  : Column(
                      children: [
                        TextField(
                          controller: idController,
                          style: TextStyle(
                              color: controller.themeController.theme
                                  .appBarTheme.titleTextStyle!.color),
                          decoration: InputDecoration(
                            labelText: 'ID',
                            labelStyle: TextStyle(
                                color: controller.themeController.theme
                                    .appBarTheme.titleTextStyle!.color),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: controller.themeController.theme
                                      .appBarTheme.titleTextStyle!.color!),
                            ),
                          ),
                        ),
                        TextField(
                          controller: lmsPasswordController,
                          style: TextStyle(
                              color: controller.themeController.theme
                                  .appBarTheme.titleTextStyle!.color),
                          decoration: InputDecoration(
                              labelText: 'LMS Password',
                              labelStyle: TextStyle(
                                  color: controller.themeController.theme
                                      .appBarTheme.titleTextStyle!.color),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: controller.themeController.theme
                                        .appBarTheme.titleTextStyle!.color!),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showLMSPass.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: controller.themeController.theme
                                      .appBarTheme.titleTextStyle!.color,
                                ),
                                onPressed: () {
                                  showLMSPass.value = !showLMSPass.value;
                                },
                              )),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: !showLMSPass.value,
                        ),
                        TextField(
                          controller: qalamPasswordController,
                          style: TextStyle(
                              color: controller.themeController.theme
                                  .appBarTheme.titleTextStyle!.color),
                          decoration: InputDecoration(
                            labelText: 'QALAM Password',
                            labelStyle: TextStyle(
                                color: controller.themeController.theme
                                    .appBarTheme.titleTextStyle!.color),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: controller.themeController.theme
                                      .appBarTheme.titleTextStyle!.color!),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showQalamPass.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: controller.themeController.theme
                                    .appBarTheme.titleTextStyle!.color,
                              ),
                              onPressed: () {
                                showQalamPass.value = !showQalamPass.value;
                              },
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: !showQalamPass.value,
                        ),
                      ],
                    ),
              const SizedBox(height: 20),
              isReadInfo.value == true
                  ? const SizedBox()
                  : CustomButton(
                      title: 'Save',
                      color: ColorManager.primary,
                      textColor: ColorManager.background2,
                      widthFactor: 1,
                      onPressed: () {
                        controller.authenticationController.setCredentials(
                            idController.text,
                            lmsPasswordController.text,
                            qalamPasswordController.text);
                        controller.authenticationController
                            .toggleAutofill(true);
                        Get.back();
                      }),
              const SizedBox(height: 10),
              CustomButton(
                  title: isReadInfo.value == true ? "Close" : 'Cancel',
                  color: controller.themeController.theme.cardTheme.color!,
                  textColor: controller
                      .themeController.theme.appBarTheme.titleTextStyle!.color!,
                  widthFactor: 1,
                  onPressed: () {
                    isReadInfo.value == true
                        ? isReadInfo.value = false
                        : Get.back();
                  }),
            ],
          ),
        )),
  ));
}
