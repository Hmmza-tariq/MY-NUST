import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/modules/widgets/error_widget.dart';
import 'package:nust/app/modules/widgets/loading.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../resources/color_manager.dart';
import '../controllers/web_controller.dart';

class WebView extends GetView<WebController> {
  const WebView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background1,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: Get.width,
              height: Get.height,
              child: Obx(() => !controller.isError.value
                  ? WebViewWidget(
                      controller: controller.webViewController,
                    )
                  : const ErrorScreen(
                      details: "No Internet Connection",
                    )),
            ),
            Obx(() => controller.isLoading.value
                ? showFullPageLoading(controller.status)
                : const SizedBox()),
          ],
        ),
      ),
      floatingActionButton: Obx(() => controller.isLoading.value
          ? const SizedBox()
          : FloatingActionButton(
              onPressed: () {
                controller.reload();
              },
              backgroundColor: ColorManager.primary.withOpacity(0.5),
              elevation: 0,
              highlightElevation: 0,
              child:
                  const Icon(Icons.refresh_rounded, color: ColorManager.white),
            )),
    );
  }
}
