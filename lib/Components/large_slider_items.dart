import 'package:flutter/widgets.dart';
import 'package:mynust/Screens/Web%20view/notice_board_screen.dart';
import 'package:mynust/Screens/Web%20view/portal_screen.dart';

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
      navigateScreen: const PortalScreen(
        initialUrl:
            'https://lms.nust.edu.pk/portal/calendar/view.php?view=month',
      ),
    ),
    LargeSliderListData(
      imagePath: 'assets/images/qalam.png',
      name: 'Qalam',
      navigateScreen: const PortalScreen(
        initialUrl: 'https://qalam.nust.edu.pk/',
      ),
    ),
    LargeSliderListData(
      imagePath: 'assets/images/noticeBoard.png',
      name: 'Notice Board',
      navigateScreen: const NoticeBoardScreen(),
    )
  ];
}
