import 'package:flutter/material.dart';
import 'package:mynust/Screens/Absolutes/calc_absolute_screen.dart';
import 'package:mynust/Screens/Web%20view/downloaded_files_screen.dart';
import 'package:mynust/Screens/GPA/calc_gpa_screen.dart';
import 'package:mynust/Screens/Task/calendar_screen.dart';
import 'package:mynust/Screens/Task/todo_screen.dart';

import '../Screens/Aggregate/calc_aggregate_screen.dart';
import '../Screens/GPA/calc_cgpa_screen.dart';
import '../Screens/Gallery/gallery_screen.dart';

class SmallSliderListData {
  SmallSliderListData({
    this.title = '',
    this.startColor = '#ffffff',
    this.endColor = '#ffffff',
    this.subtitle,
    required this.icon,
    required this.page,
  });

  String title;
  String startColor;
  String endColor;
  List<String>? subtitle;
  IconData icon;
  Widget page;

  static List<SmallSliderListData> tabIconsList = <SmallSliderListData>[
    SmallSliderListData(
      title: 'Calculate',
      subtitle: <String>['CGPA'],
      startColor: '#79F1A4',
      endColor: '#0E5C06',
      icon: Icons.calculate_rounded,
      page: const CalcCgpaScreen(),
    ),
    SmallSliderListData(
      title: 'To Do',
      subtitle: <String>['Tasks'],
      startColor: '#FE95B6',
      endColor: '#FF5287',
      icon: Icons.check_box_rounded,
      page: const ScheduleTaskScreen(),
    ),
    SmallSliderListData(
      title: 'Study',
      subtitle: <String>['Notes'],
      startColor: '#A9A9A9', // Dark Gray
      endColor: '#808080', // Gray
      icon: Icons.filter_rounded,
      page: const GalleryScreen(),
    ),
    SmallSliderListData(
      title: 'Calendar',
      subtitle: <String>['Events'],
      startColor: '#6F72CA',
      endColor: '#1E1466',
      icon: Icons.calendar_month_rounded,
      page: const CalendarScreen(),
    ),
    SmallSliderListData(
      title: 'Downloaded',
      subtitle: <String>['Files'],
      startColor: '#8BC34A',
      endColor: '#689F38',
      icon: Icons.download_for_offline_rounded,
      page: const DownloadedFilesScreen(),
    ),
    SmallSliderListData(
      title: 'Calculate',
      subtitle: <String>['SGPA'],
      startColor: '#FA7D82',
      endColor: '#FFB295',
      icon: Icons.calculate_rounded,
      page: const CalcGpaScreen(),
    ),
    SmallSliderListData(
      title: 'Calculate',
      subtitle: <String>['Absolutes'],
      startColor: '#FF5733',
      endColor: '#FFB24E',
      icon: Icons.calculate_rounded,
      page: const CalcAbsoluteScreen(),
    ),
    SmallSliderListData(
      title: 'Calculate',
      subtitle: <String>['Aggregate'],
      startColor: '#6DE4FC',
      endColor: '#0C3A5D',
      icon: Icons.calculate_rounded,
      page: const CalcAggregateScreen(),
    ),
  ];
}
