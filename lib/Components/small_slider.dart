import 'package:flutter/material.dart';
import 'package:mynust/Components/small_slider_items.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../Components/hex_color.dart';
import '../Core/app_theme.dart';
import '../Provider/theme_provider.dart';

class SmallSlider extends StatefulWidget {
  const SmallSlider(
      {Key? key,
      this.mainScreenAnimationController,
      this.mainScreenAnimation,
      required this.isWrap})
      : super(key: key);

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final bool isWrap;
  @override
  SmallSliderState createState() => SmallSliderState();
}

class SmallSliderState extends State<SmallSlider>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  List<SmallSliderListData> sliderListData = SmallSliderListData.tabIconsList;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
            child: SizedBox(
              height: widget.isWrap ? 300 : 160,
              width: double.infinity,
              child: widget.isWrap
                  ? Center(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          sliderListData.length,
                          (index) {
                            final int count = sliderListData.length > 10
                                ? 10
                                : sliderListData.length;
                            final Animation<double> animation =
                                Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: animationController!,
                                curve: Interval((1 / count) * index, 1.0,
                                    curve: Curves.fastOutSlowIn),
                              ),
                            );
                            animationController?.forward();

                            return SliderView(
                              sliderListData: sliderListData[index],
                              animation: animation,
                              animationController: animationController!,
                              isWrap: widget.isWrap,
                            );
                          },
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(right: 16, left: 16),
                      itemCount: sliderListData.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        final int count = sliderListData.length > 10
                            ? 10
                            : sliderListData.length;
                        final Animation<double> animation =
                            Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animationController!,
                            curve: Interval((1 / count) * index, 1.0,
                                curve: Curves.fastOutSlowIn),
                          ),
                        );
                        animationController?.forward();

                        return SliderView(
                          sliderListData: sliderListData[index],
                          animation: animation,
                          animationController: animationController!,
                          isWrap: widget.isWrap,
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}

class SliderView extends StatelessWidget {
  const SliderView(
      {Key? key,
      this.sliderListData,
      this.animationController,
      this.animation,
      required this.isWrap})
      : super(key: key);

  final SmallSliderListData? sliderListData;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final bool isWrap;
  @override
  Widget build(BuildContext context) {
    bool isLightMode = Provider.of<ThemeProvider>(context).isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation!.value), 0.0, 0.0),
            child: SizedBox(
              width: isWrap ? 110 : 125,
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                      context,
                      PageTransition(
                          duration: const Duration(milliseconds: 500),
                          type: PageTransitionType.rightToLeft,
                          alignment: Alignment.bottomCenter,
                          child: sliderListData!.page,
                          inheritTheme: true,
                          ctx: context));
                },
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: isWrap ? 18 : 22,
                          left: isWrap ? 8 : 8,
                          right: isWrap ? 4 : 8,
                          bottom: isWrap ? 8 : 12),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: !isLightMode
                              ? null
                              : <BoxShadow>[
                                  BoxShadow(
                                      color: HexColor(sliderListData!.endColor)
                                          .withOpacity(0.6),
                                      offset: const Offset(1.1, 4.0),
                                      blurRadius: 8.0),
                                ],
                          gradient: LinearGradient(
                            colors: <HexColor>[
                              HexColor(sliderListData!.startColor),
                              HexColor(sliderListData!.endColor),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(54.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: isWrap ? 28 : 34,
                              left: isWrap ? 8 : 16,
                              right: isWrap ? 4 : 16,
                              bottom: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                sliderListData!.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontName,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.2,
                                  color: AppTheme.white,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 2, bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      sliderListData!.subtitle!.join('\n'),
                                      style: const TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 8,
                                        letterSpacing: 0.2,
                                        color: AppTheme.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.nearlyWhite,
                                  shape: BoxShape.circle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: AppTheme.nearlyBlack
                                            .withOpacity(0.4),
                                        offset: const Offset(8.0, 8.0),
                                        blurRadius: 8.0),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Icon(
                                    sliderListData!.icon,
                                    color: HexColor(sliderListData!.endColor),
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
