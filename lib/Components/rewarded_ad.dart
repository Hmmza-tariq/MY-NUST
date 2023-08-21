import 'package:google_mobile_ads/google_mobile_ads.dart';

class ResultAd {
  static const adUnitId = 'ca-app-pub-8875342677218505/9904823569';
  static RewardedInterstitialAd? _rewardedInterstitialAd;
  static bool isAdLoaded = false;

  static void loadAd() {
    RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('$ad loaded.');
          isAdLoaded = true;
          _rewardedInterstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedInterstitialAd failed to load: $error');
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
