import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nust/app/domain/portal/portal_load_state.dart';
import 'package:nust/app/modules/widgets/app_glass_surface.dart';
import 'package:nust/app/resources/color_manager.dart';
import 'package:nust/app/resources/theme_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/web_controller.dart';

class WebView extends GetView<WebController> {
  const WebView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
          canPop: controller.canPop.value,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) controller.goBack();
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  Theme(
                    data: getLightTheme(),
                    child: _PortalToolbar(controller: controller),
                  ),
                  Expanded(
                    child: Obx(() {
                      final phase = controller.phase.value;
                      return Theme(
                        data: getLightTheme(),
                        child: Stack(
                          children: [
                            if (phase.showsPage &&
                                controller.webViewController != null)
                              Positioned.fill(
                                child: WebViewWidget(
                                  controller: controller.webViewController!,
                                ),
                              ),
                            if (phase == PortalPhase.initializing)
                              const _StartingState(),
                            if (phase == PortalPhase.offline ||
                                phase == PortalPhase.failed)
                              _ErrorState(
                                offline: phase == PortalPhase.offline,
                                message: controller.errorMessage.value,
                                onRetry: controller.reload,
                                onBrowser: controller.openInBrowser,
                              ),
                            if (phase == PortalPhase.slow)
                              _SlowBanner(
                                onRetry: controller.reload,
                                onBrowser: controller.openInBrowser,
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class _PortalToolbar extends StatelessWidget {
  const _PortalToolbar({required this.controller});

  final WebController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: AppGlassSurface(
        borderRadius: 16,
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: controller.goBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.pageTitle.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            controller.currentUrl.value.isEmpty
                                ? 'Secure portal view'
                                : controller.currentUrl.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Reload',
                      onPressed: controller.reload,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'More options',
                      onSelected: (value) {
                        if (value == 'forward') controller.goForward();
                        if (value == 'browser') controller.openInBrowser();
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'forward',
                          child: ListTile(
                            leading: Icon(Icons.arrow_forward_rounded),
                            title: Text('Forward'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'browser',
                          child: ListTile(
                            leading: Icon(Icons.open_in_browser_rounded),
                            title: Text('Open in browser'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (controller.phase.value.isBusy)
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: ColorManager.primary,
                  backgroundColor: Colors.transparent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartingState extends StatelessWidget {
  const _StartingState();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text('Opening portal…',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
}

class _SlowBanner extends StatelessWidget {
  const _SlowBanner({required this.onRetry, required this.onBrowser});

  final VoidCallback onRetry;
  final VoidCallback onBrowser;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: AppGlassSurface(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                    child: Text('The portal is taking longer than usual.')),
                TextButton(onPressed: onRetry, child: const Text('Retry')),
                TextButton(onPressed: onBrowser, child: const Text('Browser')),
              ],
            ),
          ),
        ),
      );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.offline,
    required this.message,
    required this.onRetry,
    required this.onBrowser,
  });

  final bool offline;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBrowser;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  offline
                      ? Icons.cloud_off_rounded
                      : Icons.web_asset_off_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  offline ? 'You’re offline' : 'Portal unavailable',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onBrowser,
                      icon: const Icon(Icons.open_in_browser_rounded),
                      label: const Text('Open in browser'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
