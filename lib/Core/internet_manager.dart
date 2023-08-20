import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mynust/Provider/internet_provider.dart';
import 'package:provider/provider.dart';

import '../Components/hex_color.dart';

class InternetManager {
  static late ConnectivityResult result;
  static late StreamSubscription subscription;
  static void checkInternet(context, {int count = 2}) async {
    InternetProvider ip = Provider.of<InternetProvider>(context, listen: false);
    result = await Connectivity().checkConnectivity();
    if (result != ConnectivityResult.none) {
      ip.setConnection(true);
      count = 0;
    } else {
      ip.setConnection(false);
      count--;
      showDialogBox(context, count);
    }
  }

  static void showDialogBox(BuildContext context, int count) {
    showDialog(
      context: context,
      builder: (context) {
        if (count != 0) {
          Future.delayed(const Duration(seconds: 3), () {
            checkInternet(context, count: count);
            Navigator.of(context).pop();
          });
        } else {
          Navigator.of(context).pop();
        }
        return LoadingAnimationWidget.hexagonDots(
          size: 40,
          color: HexColor('#0F6FC5'),
        );
      },
    );
  }

  static void startStreaming(context) {
    subscription = Connectivity().onConnectivityChanged.listen((event) async {
      checkInternet(context);
    });
  }
}
