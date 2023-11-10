import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ResultAd {
  static AppOpenAd? _appOpenAd;
  static bool isAdLoaded = false;

  static void loadAd() {
    AppOpenAd.load(
      adUnitId: 'ca-app-pub-8875342677218505/4721874523',
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('$ad loaded.');
          }
          isAdLoaded = true;
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            print('RewardedInterstitialAd failed to load: $error');
          }
          isAdLoaded = false;
        },
      ),
      orientation: AppOpenAd.orientationPortrait,
    );
  }

  static void playAd() {
    (isAdLoaded) ? _appOpenAd!.show() : null;
  }
}
