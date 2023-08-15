import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

late ConnectivityResult result;
late StreamSubscription subscription;
bool isConnected = true;
checkInternet(context) async {
  result = await Connectivity().checkConnectivity();
  if (result != ConnectivityResult.none) {
    isConnected = true;
  } else {
    isConnected = false;
    showDialogBox(context);
  }
}

showDialogBox(context) {
  showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
            title: const Text("No Internet"),
            content: const Text("Please check your internet connection"),
            actions: [
              CupertinoButton.filled(
                  child: const Text("Retry"),
                  onPressed: () {
                    Navigator.pop(context);
                    checkInternet(context);
                  })
            ],
          )); // CupertinoAlertDialog
}

startStreaming(context) {
  subscription = Connectivity().onConnectivityChanged.listen((event) async {
    checkInternet(context);
  });
}
