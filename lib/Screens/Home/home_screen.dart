import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:info_popup/info_popup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../Components/large_slider.dart';
import '../../Components/small_slider.dart';
import '../../Components/small_slider_items.dart';
import '../../Core/app_theme.dart';
import '../../Components/large_slider_items.dart';
import '../../Core/theme_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<LargeSliderListData> homeList = LargeSliderListData.homeList;
  AnimationController? animationController;
  AnimationController? scaleAnimationController;
  final carouselController = CarouselController();
  bool isWrap = true;
  int itemCount = 1;
  int currentPageIndex = 0;
  late NativeAd? _nativeAd_1;
  late NativeAd? _nativeAd_2;
  bool _isAdLoaded = false;
  List<SmallSliderListData> sliderListData = SmallSliderListData.tabIconsList;
  bool _isLightMode = false;
  var adStyle = NativeTemplateTextStyle(
      textColor: AppTheme.notWhite,
      backgroundColor: Colors.transparent,
      style: NativeTemplateFontStyle.normal,
      size: 12.0);
  @override
  void initState() {
    loadAd_1();
    loadAd_2();
    _loadWrap();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    scaleAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
  }

  void loadAd_1() {
    adStyle = NativeTemplateTextStyle(
        textColor: _isLightMode ? AppTheme.nearlyBlack : Colors.white,
        backgroundColor: Colors.transparent,
        style: NativeTemplateFontStyle.normal,
        size: 12.0);
    if (homeList.last.name != 'AD') {
      _nativeAd_1 = NativeAd(
          adUnitId: 'ca-app-pub-8875342677218505/7272751369',
          listener: NativeAdListener(
            onAdLoaded: (ad) {
              if (kDebugMode) {
                print('$NativeAd loaded #1.');
              }
              setState(() {
                homeList.add(LargeSliderListData(
                  isWidget: true,
                  imagePath: 'assets/images/Error.png',
                  name: 'AD',
                  widget: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 180,
                      minHeight: 160,
                      maxWidth: 220,
                      maxHeight: 200,
                    ),
                    child: AdWidget(ad: _nativeAd_1!),
                  ),
                ));
              });
            },
            onAdFailedToLoad: (ad, error) {
              if (kDebugMode) {
                print('$NativeAd failedToLoad #1: $error');
              }
              ad.dispose();
            },
            onAdClicked: (ad) {},
            onAdImpression: (ad) {},
            onAdClosed: (ad) {},
            onAdOpened: (ad) {},
            onAdWillDismissScreen: (ad) {},
            onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
          ),
          request: const AdRequest(),
          nativeTemplateStyle: NativeTemplateStyle(
            templateType: TemplateType.medium,
            mainBackgroundColor:
                _isLightMode ? Colors.white : AppTheme.nearlyBlack,
            cornerRadius: 10.0,
            callToActionTextStyle: adStyle,
            primaryTextStyle: adStyle,
            secondaryTextStyle: adStyle,
            tertiaryTextStyle: adStyle,
          ))
        ..load();
    }
  }

  void loadAd_2() {
    adStyle = NativeTemplateTextStyle(
        textColor: _isLightMode ? AppTheme.nearlyBlack : Colors.white,
        backgroundColor: Colors.transparent,
        style: NativeTemplateFontStyle.normal,
        size: 12.0);
    _nativeAd_2 = NativeAd(
        adUnitId: 'ca-app-pub-8875342677218505/3093833203',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            if (kDebugMode) {
              print('$NativeAd loaded #2.');
            }
            setState(() {
              _isAdLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            if (kDebugMode) {
              print('$NativeAd failedToLoad #2: $error');
            }
            setState(() {
              _isAdLoaded = false;
            });
            ad.dispose();
          },
          onAdClicked: (ad) {},
          onAdImpression: (ad) {},
          onAdClosed: (ad) {},
          onAdOpened: (ad) {},
          onAdWillDismissScreen: (ad) {},
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.medium,
          mainBackgroundColor:
              _isLightMode ? Colors.white : AppTheme.nearlyBlack,
          cornerRadius: 20.0,
          callToActionTextStyle: adStyle,
          primaryTextStyle: adStyle,
          secondaryTextStyle: adStyle,
          tertiaryTextStyle: adStyle,
        ))
      ..load();
  }

  @override
  void dispose() {
    animationController?.dispose();
    scaleAnimationController?.dispose();
    super.dispose();
  }

  void _loadWrap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isWrap = prefs.getBool('isWrap') ?? true;
    });
  }

  void _saveWrap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isWrap', isWrap);
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    bool isLightMode = themeProvider.isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    _isLightMode = isLightMode;
    itemCount = homeList.length;

    Animation<double> scaleAnimation1 =
        Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: scaleAnimationController!,
        curve: const Interval(0, 1, curve: Curves.bounceOut),
      ),
    );
    Animation<double> scaleAnimation2 = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: scaleAnimationController!,
        curve: const Interval(0, 1, curve: Curves.bounceIn),
      ),
    );
    scaleAnimationController?.forward();

    return Scaffold(
      backgroundColor: isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
      body: SingleChildScrollView(
        child: SafeArea(
          child: FutureBuilder<bool>(
            future: getData(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    appBar(isLightMode),
                    SizedBox(
                      height: 240,
                      child: CarouselSlider.builder(
                          carouselController: carouselController,
                          itemCount: itemCount,
                          itemBuilder: (context, index, realIndex) {
                            animationController?.forward();
                            return GestureDetector(
                              onTap: () {
                                (!homeList[index].isWidget)
                                    ? Navigator.push<dynamic>(
                                        context,
                                        MaterialPageRoute<dynamic>(
                                          builder: (BuildContext context) =>
                                              homeList[index].navigateScreen!,
                                        ),
                                      )
                                    : null;
                              },
                              child: Stack(
                                alignment: AlignmentDirectional.bottomCenter,
                                children: [
                                  LargeSlider(
                                    listData: homeList[index],
                                  ),
                                  AnimatedBuilder(
                                      animation: scaleAnimationController!,
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return ScaleTransition(
                                            scale: (index == currentPageIndex)
                                                ? scaleAnimation1
                                                : scaleAnimation2,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isLightMode
                                                    ? AppTheme.white
                                                    : AppTheme.nearlyBlack,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: isLightMode
                                                        ? AppTheme.notWhite
                                                        : themeProvider
                                                            .primaryColor,
                                                    width: 3),
                                                boxShadow: !isLightMode
                                                    ? null
                                                    : <BoxShadow>[
                                                        BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.6),
                                                            offset:
                                                                const Offset(
                                                                    4, 4),
                                                            blurRadius: 8.0),
                                                      ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  homeList[index].name,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: isLightMode
                                                        ? AppTheme.nearlyBlack
                                                        : AppTheme.white,
                                                  ),
                                                ),
                                              ),
                                            ));
                                      })
                                ],
                              ),
                            );
                          },
                          options: CarouselOptions(
                              viewportFraction: .6,
                              autoPlay: true,
                              enableInfiniteScroll: true,
                              autoPlayAnimationDuration:
                                  const Duration(seconds: 5),
                              enlargeCenterPage: true,
                              onPageChanged: (index, reason) {
                                setState(() => currentPageIndex = index);
                                scaleAnimationController?.reset();
                              })),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: AnimatedSmoothIndicator(
                        onDotClicked: animateToSlide,
                        effect: ExpandingDotsEffect(
                            dotWidth: 12,
                            dotHeight: 12,
                            activeDotColor: isLightMode
                                ? AppTheme.nearlyBlack
                                : Colors.white),
                        activeIndex: currentPageIndex,
                        count: itemCount,
                      ),
                    ),
                    SmallSlider(
                      mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0)
                          .animate(CurvedAnimation(
                              parent: animationController!,
                              curve: Interval(
                                  (1 / itemCount) * currentPageIndex, 1.0,
                                  curve: Curves.fastEaseInToSlowEaseOut))),
                      mainScreenAnimationController: animationController,
                      isWrap: isWrap,
                    ),
                    const SizedBox(height: 16),
                    Visibility(
                      visible: _isAdLoaded,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width / 1.5,
                            minHeight: 350,
                            maxWidth: MediaQuery.of(context).size.width / 1.2,
                            maxHeight: 390,
                          ),
                          child: Stack(
                            alignment: AlignmentDirectional.bottomCenter,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 18.0),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.nearlyBlack,
                                      borderRadius: const BorderRadius.only(
                                        bottomRight: Radius.circular(22.0),
                                        bottomLeft: Radius.circular(22.0),
                                        topLeft: Radius.circular(4.0),
                                        topRight: Radius.circular(4.0),
                                      ),
                                      border: Border.all(
                                          color: isLightMode
                                              ? AppTheme.notWhite
                                              : themeProvider.primaryColor,
                                          width: 3),
                                      boxShadow: !isLightMode
                                          ? null
                                          : <BoxShadow>[
                                              BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.6),
                                                  offset: const Offset(4, 4),
                                                  blurRadius: 8.0),
                                            ],
                                    ),
                                    child: AdWidget(ad: _nativeAd_2!)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isLightMode
                                        ? AppTheme.white
                                        : AppTheme.nearlyBlack,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: isLightMode
                                            ? AppTheme.notWhite
                                            : themeProvider.primaryColor,
                                        width: 3),
                                    boxShadow: !isLightMode
                                        ? null
                                        : <BoxShadow>[
                                            BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.6),
                                                offset: const Offset(0, 8),
                                                blurRadius: 8.0),
                                          ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 80,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'AD ',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: isLightMode
                                                  ? AppTheme.nearlyBlack
                                                  : AppTheme.white,
                                            ),
                                          ),
                                          InfoPopupWidget(
                                            contentOffset: const Offset(0, 0),
                                            arrowTheme: InfoPopupArrowTheme(
                                              arrowDirection:
                                                  ArrowDirection.down,
                                              color: isLightMode
                                                  ? const Color.fromARGB(
                                                      255, 199, 199, 199)
                                                  : const Color.fromARGB(
                                                      255, 1, 54, 98),
                                            ),
                                            contentTheme: InfoPopupContentTheme(
                                              infoContainerBackgroundColor:
                                                  isLightMode
                                                      ? const Color.fromARGB(
                                                          255, 199, 199, 199)
                                                      : const Color.fromARGB(
                                                          255, 1, 54, 98),
                                              infoTextStyle: TextStyle(
                                                color: isLightMode
                                                    ? AppTheme.nearlyBlack
                                                    : AppTheme.white,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.all(6),
                                              contentBorderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              infoTextAlign: TextAlign.center,
                                            ),
                                            dismissTriggerBehavior:
                                                PopupDismissTriggerBehavior
                                                    .anyWhere,
                                            contentTitle: ' :) ',
                                            child: const Icon(
                                              Icons.info_outline,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void animateToSlide(int index) => carouselController.animateToPage(index);
  Widget appBar(isLightMode) {
    return SizedBox(
      height: AppBar().preferredSize.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: SizedBox(
              width: AppBar().preferredSize.height - 8,
              height: AppBar().preferredSize.height - 8,
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 22,
                    color: isLightMode ? AppTheme.darkText : AppTheme.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: Container(
              width: AppBar().preferredSize.height - 8,
              height: AppBar().preferredSize.height - 8,
              color: isLightMode ? Colors.white : AppTheme.nearlyBlack,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(AppBar().preferredSize.height),
                  child: Icon(
                    isWrap ? Icons.dashboard : Icons.view_agenda,
                    color: isLightMode ? AppTheme.darkGrey : AppTheme.white,
                  ),
                  onTap: () {
                    setState(() {
                      isWrap = !isWrap;
                      _saveWrap();
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
