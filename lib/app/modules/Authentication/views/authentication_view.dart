import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/resources/color_manager.dart';
import '../../../resources/assets_manager.dart';
import '../../widgets/custom_button.dart';

import '../controllers/authentication_controller.dart';

class AuthenticationView extends GetView<AuthenticationController> {
  const AuthenticationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: ColorManager.gradientColor,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
              child: SizedBox(
                height: Get.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('User Authentication',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .titleTextStyle!
                                      .color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Center(
                              child: Image.asset(AssetsManager.logo,
                                  height: Get.height * 0.2)),
                          const SizedBox(height: 10),
                          Text(
                            'Please authenticate to continue',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .appBarTheme
                                    .titleTextStyle!
                                    .color,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    CustomButton(
                        title: 'Authenticate',
                        color: ColorManager.primary,
                        textColor: ColorManager.background2,
                        widthFactor: 1,
                        margin: 32,
                        onPressed: () async {
                          bool authenticated = await controller.authenticate();
                          if (authenticated) {
                            Get.offAllNamed(controller.page.value);
                          } else {
                            Get.snackbar('Authentication Failed',
                                'Please try again later',
                                snackPosition: SnackPosition.BOTTOM);
                          }
                        }),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
