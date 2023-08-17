import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mynust/Core/app_theme.dart';

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
  @override
  void initState() {
    (widget.icon == Icons.calculate) ? loadAd() : null;
    super.initState();
  }

  void loadAd() {
    RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            isAdLoaded = true;
            _rewardedInterstitialAd = ad;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedInterstitialAd failed to load: $error');
          setState(() {
            isAdLoaded = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: CircleAvatar(
        backgroundColor: widget.color,
        radius: 30,
        child: IconButton(
          iconSize: 30,
          onPressed: () {
            print('ad clicked: $isAdLoaded');

            isAdLoaded
                ? _rewardedInterstitialAd!.show(onUserEarnedReward:
                    (AdWithoutView ad, RewardItem rewardItem) {
                    print('ad reward: $rewardItem');
                  })
                : null;
            widget.func();
          },
          icon: Icon(widget.icon),
          color: widget.icon == Icons.add ? AppTheme.darkGrey : Colors.white,
        ),
      ),
    );
  }
}
