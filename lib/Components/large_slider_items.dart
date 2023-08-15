import 'package:flutter/widgets.dart';
import 'package:mynust/Screens/Web%20view/lms_screen.dart';
import 'package:mynust/Screens/Web%20view/qalam_screen.dart';
import 'package:mynust/Components/webview.dart';

class LargeSliderListData {
  LargeSliderListData({
    this.navigateScreen,
    this.widget,
    this.isWidget = false,
    this.imagePath = '',
    this.name = '',
  });

  Widget? navigateScreen;
  String imagePath;
  String name;
  Widget? widget;
  bool isWidget;
  static List<LargeSliderListData> homeList = [
    LargeSliderListData(
      imagePath: 'assets/images/lms.png',
      name: 'LMS',
      navigateScreen: const LmsScreen(),
    ),
    LargeSliderListData(
      imagePath: 'assets/images/qalam.png',
      name: 'Qalam',
      navigateScreen: const QalamScreen(),
    ),
    LargeSliderListData(
      imagePath: 'assets/images/ceme.png',
      name: 'Notice Board',
      navigateScreen: const WebsiteView(
          initialUrl:
              'https://ceme.nust.edu.pk/downloads/student-notice-board-ug/'),
    ),
  ];
}
