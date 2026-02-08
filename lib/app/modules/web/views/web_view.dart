import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../resources/color_manager.dart';
import '../../../routes/app_pages.dart';
import '../controllers/web_controller.dart';
import 'package:nust/app/modules/widgets/custom_button.dart';

class WebView extends GetView<WebController> {
  const WebView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
          canPop: controller.canPop.value,
          onPopInvokedWithResult: (pop, result) {
            final wvc = controller.webViewController;
            if (wvc == null) {
              Get.back();
              return;
            }

            wvc.canGoBack().then((value) {
              if (value) {
                controller.canPop.value = true;
                wvc.goBack();
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
            body: Stack(
              children: [
                // Webview with dynamic padding
                Obx(() => AnimatedPadding(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.only(
                        top: controller.isAppBarExpanded.value
                            ? (MediaQuery.of(context).padding.top +
                                kToolbarHeight +
                                3)
                            : MediaQuery.of(context).padding.top,
                      ),
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await controller.reload();
                        },
                        color: ColorManager.primary,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedOpacity(
                              opacity: controller.isLoading.value ? 0.3 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: SizedBox(
                                width: Get.width,
                                height: Get.height,
                                child: !controller.isError.value &&
                                        controller.isWebViewInitialized.value &&
                                        controller.webViewController != null
                                    ? WebViewWidget(
                                        controller:
                                            controller.webViewController!,
                                        gestureRecognizers: const {},
                                      )
                                    : _buildErrorState(),
                              ),
                            ),
                            if (controller.isLoading.value)
                              Container(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 4,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                ColorManager.primary),
                                        value: controller.status.value > 0
                                            ? controller.status.value / 100
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      controller.status.value > 0
                                          ? 'Loading ${controller.status.value}%'
                                          : 'Loading...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: controller.themeController.theme
                                            .appBarTheme.titleTextStyle!.color,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      controller.currentUrl.value.isNotEmpty
                                          ? controller.currentUrl.value
                                          : 'Please wait...',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: controller.themeController.theme
                                            .appBarTheme.titleTextStyle!.color
                                            ?.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (controller.initError.value)
                              _buildInitErrorState(),
                          ],
                        ),
                      ),
                    )),
                // Collapsible AppBar
                _buildCollapsibleAppBar(),
              ],
            ),
          ),
        ));
  }

  Widget _buildCollapsibleAppBar() {
    return Obx(() => AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 0,
          left: 0,
          right: 0,
          child: controller.isAppBarExpanded.value
              ? _buildExpandedAppBar()
              : _buildCollapsedAppBar(),
        ));
  }

  Widget _buildCollapsedAppBar() {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              controller.toggleAppBar();
            },
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              topRight: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  topRight: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
                color: controller
                    .themeController.theme.appBarTheme.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: controller.themeController.theme.appBarTheme
                            .titleTextStyle?.color
                            ?.withValues(alpha: 0.1) ??
                        ColorManager.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.isLoading.value)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2.0, vertical: 2.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              ColorManager.white),
                          // value: controller.status.value / 100,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.keyboard_arrow_left_rounded,
                      color: controller.themeController.theme.appBarTheme
                          .titleTextStyle!.color,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedAppBar() {
    Color iconColor =
        controller.themeController.theme.appBarTheme.titleTextStyle!.color!;
    Color bgColor =
        controller.themeController.theme.appBarTheme.backgroundColor!;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: kToolbarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: iconColor,
                    ),
                    onPressed: () async {
                      final wvc = controller.webViewController;
                      if (wvc == null) {
                        Get.back();
                        return;
                      }

                      if (await wvc.canGoBack()) {
                        wvc.goBack();
                      } else {
                        if (Get.previousRoute.isEmpty) {
                          Get.offAllNamed(Routes.HOME);
                        } else {
                          Get.back();
                        }
                      }
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.pageTitle.value.isEmpty
                              ? 'Loading...'
                              : controller.pageTitle.value,
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (controller.currentUrl.value.isNotEmpty)
                          Text(
                            controller.currentUrl.value,
                            style: TextStyle(
                              color: iconColor.withValues(alpha: 0.6),
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (!controller.isLoading.value && !controller.isError.value)
                    IconButton(
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: iconColor,
                      ),
                      onPressed: () {
                        controller.reload();
                      },
                    ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: iconColor,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: bgColor,
                    elevation: 4,
                    onSelected: (value) {
                      switch (value) {
                        case 'forward':
                          controller.goForward();
                          break;
                        case 'hide':
                          controller.toggleAppBar();
                          break;
                        case 'home':
                          Get.offAllNamed(Routes.HOME);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'forward',
                        child: Row(
                          children: [
                            Icon(Icons.arrow_forward_ios_rounded,
                                color: iconColor, size: 18),
                            SizedBox(width: 8),
                            Text('Forward', style: TextStyle(color: iconColor)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'hide',
                        child: Row(
                          children: [
                            Icon(Icons.keyboard_arrow_up_rounded,
                                color: iconColor, size: 18),
                            SizedBox(width: 8),
                            Text('Hide', style: TextStyle(color: iconColor)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'home',
                        child: Row(
                          children: [
                            Icon(Icons.home_rounded,
                                color: iconColor, size: 18),
                            SizedBox(width: 8),
                            Text('Home', style: TextStyle(color: iconColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 3,
              child: controller.isLoading.value
                  ? LinearProgressIndicator(
                      value: controller.status.value / 100,
                      backgroundColor: ColorManager.lightGrey1,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          ColorManager.primary),
                      minHeight: 3,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 80,
            color: ColorManager.lightGrey1,
          ),
          const SizedBox(height: 24),
          Text(
            'No Internet Connection',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: controller
                  .themeController.theme.appBarTheme.titleTextStyle!.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: controller
                  .themeController.theme.appBarTheme.titleTextStyle!.color
                  ?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            title: 'Retry',
            color: ColorManager.primary,
            textColor: ColorManager.white,
            widthFactor: 0.5,
            onPressed: () {
              controller.reload();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInitErrorState() {
    return Container(
      padding: const EdgeInsets.all(32),
      color: controller.themeController.theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 80,
            color: ColorManager.error,
          ),
          const SizedBox(height: 24),
          Text(
            'Failed to Load',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: controller
                  .themeController.theme.appBarTheme.titleTextStyle!.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: controller
                  .themeController.theme.appBarTheme.titleTextStyle!.color
                  ?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            title: 'Try Again',
            color: ColorManager.primary,
            textColor: ColorManager.white,
            widthFactor: 0.5,
            onPressed: () {
              controller.initializeWebView();
            },
          ),
        ],
      ),
    );
  }
}
