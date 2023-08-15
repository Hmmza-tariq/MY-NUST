import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Core/app_Theme.dart';
import '../Core/theme_provider.dart';
import 'large_slider_items.dart';

class LargeSlider extends StatelessWidget {
  const LargeSlider({Key? key, this.listData}) : super(key: key);

  final LargeSliderListData? listData;
  @override
  Widget build(BuildContext context) {
    bool hasWidget = (listData!.widget != null);
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isLightMode = themeProvider.isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  isLightMode ? AppTheme.notWhite : themeProvider.primaryColor,
              width: 3),
          boxShadow: !isLightMode
              ? null
              : <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      offset: const Offset(4, 4),
                      blurRadius: 8.0),
                ],
        ),
        child: AspectRatio(
          aspectRatio: 4 / 3.5,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(9.0)),
            child: !hasWidget
                ? Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      Positioned.fill(
                        child: Image.asset(
                          listData!.imagePath,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.grey.withOpacity(0.2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                    ],
                  )
                : Center(child: listData!.widget),
          ),
        ),
      ),
    );
  }
}
