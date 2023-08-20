import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mynust/Core/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.func,
    required this.icon,
    required this.color,
  });
  final Function() func;
  final IconData icon;
  final Color color;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  final adUnitId = 'ca-app-pub-8875342677218505/9904823569';
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool isAdLoaded = false;
  bool adBlock = true;
  int counter = 0;
  @override
  void initState() {
    super.initState();
    //_loadAdBlocker();
    loadAd();
  }

  void loadAd() {
    RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.,counter: $counter 1511');
          setState(() {
            isAdLoaded = true;
            _rewardedInterstitialAd = ad;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint(
              'RewardedInterstitialAd failed to load: $error,counter: $counter  1511');
          setState(() {
            isAdLoaded = false;
          });
        },
      ),
    ).then((value) => (isAdLoaded && (counter == 0))
        ? _rewardedInterstitialAd!.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {})
        : null);
  }

  Future<void> _loadAdBlocker() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('adBlock') ?? 5;
    await prefs.setInt('adBlock', (value == 0) ? 0 : (value--));
    setState(() {
      counter = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: FloatingActionButton(
          heroTag: null,
          backgroundColor: widget.color,
          onPressed: () {
            (isAdLoaded && (counter == 0))
                ? _rewardedInterstitialAd!
                    .show(
                        onUserEarnedReward:
                            (AdWithoutView ad, RewardItem rewardItem) {})
                    .then((value) => widget.func())
                : widget.func();
          },
          child: Icon(
            widget.icon,
            size: 30,
            color: widget.icon == Icons.add ? AppTheme.darkGrey : Colors.white,
          )),
    );
  }
}
