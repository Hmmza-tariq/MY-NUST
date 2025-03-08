import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nust/app/modules/widgets/error_widget.dart';
import 'package:nust/app/modules/widgets/custom_loading.dart';
import 'package:nust/app/resources/assets_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../resources/color_manager.dart';
import '../../../routes/app_pages.dart';
import '../controllers/web_controller.dart';

class WebView extends GetView<WebController> {
  const WebView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
          canPop: controller.canPop.value,
          onPopInvokedWithResult: (pop, result) {
            controller.webViewController.canGoBack().then((value) {
              if (value) {
                controller.canPop.value = true;
                controller.webViewController.goBack();
              } else {
                controller.canPop.value = false;
                if (Get.previousRoute.isEmpty) {
                  Get.offAllNamed(Routes.HOME);
                } else {
                  Get.back();
                }
              }
            });
          },
          child: Scaffold(
            backgroundColor:
                controller.themeController.theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: Get.width,
                    height: Get.height,
                    child: !controller.isError.value
                        ? WebViewWidget(
                            controller: controller.webViewController,
                            gestureRecognizers: const {},
                          )
                        : const ErrorScreen(
                            details: "No Internet Connection",
                          ),
                  ),
                  controller.isLoading.value
                      ? showFullPageLoading(controller.status)
                      : const SizedBox(),
                  if (controller.initError.value)
                    const ErrorScreen(
                      details:
                          "An error occurred while initializing the web view",
                    ),
                ],
              ),
            ),
            floatingActionButton: controller.isLoading.value
                ? const SizedBox()
                : FloatingActionButton(
                    onPressed: () {
                      controller.reload();
                    },
                    backgroundColor:
                        ColorManager.primary.withValues(alpha: 0.5),
                    elevation: 0,
                    highlightElevation: 0,
                    child: SvgPicture.asset(
                      AssetsManager.refresh,
                      width: 40,
                      colorFilter: const ColorFilter.mode(
                          ColorManager.background2, BlendMode.srcIn),
                    ),
                  ),
          ),
        ));
  }
}
