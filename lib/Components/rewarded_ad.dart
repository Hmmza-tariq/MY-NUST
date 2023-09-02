import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ResultAd {
  static const adUnitId = 'ca-app-pub-8875342677218505/6914141218';
  static RewardedInterstitialAd? _rewardedInterstitialAd;
  static bool isAdLoaded = false;

  static void loadAd() {
    RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('$ad loaded.');
          }
          isAdLoaded = true;
          _rewardedInterstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            print('RewardedInterstitialAd failed to load: $error');
          }
          isAdLoaded = false;
        },
      ),
    );
  }

  static void playAd() {
    (isAdLoaded)
        ? _rewardedInterstitialAd!.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {})
        : null;
  }
}
