import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InternetProvider with ChangeNotifier {
  bool isConnected = true;
  late WebViewController webViewController;

  void setConnection(bool option) {
    isConnected = option;
    if (isConnected == true) {
      webViewController.reload();
    }
    notifyListeners();
  }
}
