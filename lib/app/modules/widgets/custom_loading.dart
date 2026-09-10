import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_glass_surface.dart';

Widget showFullPageLoading(RxInt percentage) {
  return ColoredBox(
    color: Colors.black.withValues(alpha: .38),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: AppGlassSurface(
          borderRadius: 22,
          padding: const EdgeInsets.all(22),
          child: Obx(() {
            final value = percentage.value.clamp(0, 100);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        value > 0 ? 'Loading… $value%' : 'Loading…',
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (value > 0) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: value / 100),
                ],
                const SizedBox(height: 12),
                Text(
                  'If this takes too long, return and try again.',
                  style: Get.textTheme.bodySmall,
                ),
              ],
            );
          }),
        ),
      ),
    ),
  );
}

Widget showLoading() => const Center(
      child: SizedBox.square(
        dimension: 28,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );

Widget heightLoading(double height) => SizedBox(
      height: height,
      child: showLoading(),
    );

void closeLoading() {
  if (Get.isDialogOpen ?? false) Get.back();
}
