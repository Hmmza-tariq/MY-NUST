import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'database_controller.dart';

class ReviewPromptController extends GetxController {
  ReviewPromptController({InAppReview? inAppReview})
      : _inAppReview = inAppReview ?? InAppReview.instance;

  static const _minimumSuccessfulOutcomes = 4;
  static const _countKey = 'review-successful-outcomes';
  static const _promptedVersionKey = 'review-prompted-version';

  final InAppReview _inAppReview;
  final DatabaseController _database = Get.find();
  bool _requestInProgress = false;

  Future<void> recordSuccessfulOutcome() async {
    if (_requestInProgress || kDebugMode) return;

    final previous = int.tryParse(await _database.getData(_countKey)) ?? 0;
    final count = previous + 1;
    await _database.setData(_countKey, '$count');
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

    if (count < _minimumSuccessfulOutcomes ||
        await _database.getData(_promptedVersionKey) == appVersion) {
      return;
    }

    _requestInProgress = true;
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        await _database.setData(_promptedVersionKey, appVersion);
      }
    } catch (error) {
      debugPrint('In-app review request skipped: $error');
    } finally {
      _requestInProgress = false;
    }
  }
}
