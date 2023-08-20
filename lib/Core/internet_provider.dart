import 'package:flutter/material.dart';

class InternetProvider with ChangeNotifier {
  bool isConnected = true;

  void setConnection(bool option) {
    isConnected = option;
    notifyListeners();
  }
}
