import 'package:flutter/material.dart';
import 'package:info_popup/info_popup.dart';
import 'package:mynust/Core/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Provider/theme_provider.dart';

class LinksScreen extends StatefulWidget {
  const LinksScreen({super.key});

  @override
  State<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> {
  List<LinkWidget> linksCE = [
    const LinkWidget(
        link:
            "https://nustedupk0-my.sharepoint.com/personal/mamasood_ce41ceme_student_nust_edu_pk/_layouts/15/onedrive.aspx?ga=1&id=%2Fpersonal%2Fmamasood%5Fce41ceme%5Fstudent%5Fnust%5Fedu%5Fpk%2FDocuments%2Feme%5Fcollege%5Fopen%5Fsource%5Fdata%2FComputer%20Department",
        title: "complete"),
    const LinkWidget(
        link:
            "https://drive.google.com/drive/folders/1Ngoc5wYx6yXIT8cdQzbrImWufPTRvyHL",
        title: "semester-2"),
    const LinkWidget(
        link:
            "https://drive.google.com/drive/folders/1WdT1M4ewBdGi0s65evWFvCQX11wR_E9B",
        title: "semester-3"),
    const LinkWidget(
        link:
            "https://drive.google.com/drive/folders/12Jqk4Mv-CSsQr1kLd8HSlm_edBlhhu1p?usp=share_link",
        title: "semester-4"),
    const LinkWidget(
        link:
            "https://drive.google.com/drive/folders/1b1H02J-2je_oYeFXFd3seiO_av7K3pFK",
        title: "semester-5"),
    const LinkWidget(
        link:
            "https://drive.google.com/drive/folders/1_AZySigYR6vREUSjSLPbkIgCu03RjwAp?usp=share_link",
        title: "semester-6"),
    const LinkWidget(
        link:
            "https://drive.google.com/drive/folders/1-f6fIMb2wi7i-8BM8I6dnnI7JOvg5yKS?usp=share_link",
        title: "semester-7"),
  ];
  List<LinkWidget> linksEE = [
    const LinkWidget(
        link:
            "https://nustedupk0-my.sharepoint.com/personal/mamasood_ce41ceme_student_nust_edu_pk/_layouts/15/onedrive.aspx?ga=1&id=%2Fpersonal%2Fmamasood%5Fce41ceme%5Fstudent%5Fnust%5Fedu%5Fpk%2FDocuments%2Feme%5Fcollege%5Fopen%5Fsource%5Fdata%2FElectrical%20Department",
        title: "complete")
  ];
  List<LinkWidget> linksME = [
    const LinkWidget(
        link:
            "https://nustedupk0-my.sharepoint.com/personal/mamasood_ce41ceme_student_nust_edu_pk/_layouts/15/onedrive.aspx?ga=1&id=%2Fpersonal%2Fmamasood%5Fce41ceme%5Fstudent%5Fnust%5Fedu%5Fpk%2FDocuments%2Feme%5Fcollege%5Fopen%5Fsource%5Fdata%2Fmechanical%20dept",
        title: "complete")
  ];
  List<LinkWidget> linksMTS = [
    const LinkWidget(
        link:
            "https://nustedupk0-my.sharepoint.com/personal/mamasood_ce41ceme_student_nust_edu_pk/_layouts/15/onedrive.aspx?ga=1&id=%2Fpersonal%2Fmamasood%5Fce41ceme%5Fstudent%5Fnust%5Fedu%5Fpk%2FDocuments%2Feme%5Fcollege%5Fopen%5Fsource%5Fdata%2Fmechatronics%20dept",
        title: "complete")
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isLightMode = themeProvider.isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      backgroundColor:
          isLightMode == true ? AppTheme.white : AppTheme.nearlyBlack,
      appBar: AppBar(
        shadowColor: Colors.grey.withOpacity(0.6),
        elevation: 1,
        backgroundColor:
            isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
        leading: null,
        iconTheme:
            IconThemeData(color: isLightMode ? Colors.black : Colors.white),
        title: Text(
          'Links',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isLightMode ? Colors.black : Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InfoPopupWidget(
              contentOffset: const Offset(0, 0),
              arrowTheme: InfoPopupArrowTheme(
                arrowDirection: ArrowDirection.up,
                color: isLightMode
                    ? const Color.fromARGB(255, 199, 199, 199)
                    : const Color.fromARGB(255, 1, 54, 98),
              ),
              contentTheme: InfoPopupContentTheme(
                infoContainerBackgroundColor: isLightMode
                    ? const Color.fromARGB(255, 199, 199, 199)
                    : const Color.fromARGB(255, 1, 54, 98),
                infoTextStyle: TextStyle(
                  color: isLightMode ? AppTheme.nearlyBlack : AppTheme.white,
                ),
                contentPadding: const EdgeInsets.all(6),
                contentBorderRadius:
                    const BorderRadius.all(Radius.circular(10)),
                infoTextAlign: TextAlign.center,
              ),
              dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
              contentTitle:
                  "If you want your link for the helping material to be included, Contact support.",
              child: const Icon(
                Icons.info_outline,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DepartmentWidget(
                title: 'CEME-CE',
                isLightMode: isLightMode,
                listDpt: linksCE,
              ),
              DepartmentWidget(
                title: 'CEME-EE',
                isLightMode: isLightMode,
                listDpt: linksEE,
              ),
              DepartmentWidget(
                title: 'CEME-ME',
                isLightMode: isLightMode,
                listDpt: linksME,
              ),
              DepartmentWidget(
                title: 'CEME-MTS',
                isLightMode: isLightMode,
                listDpt: linksMTS,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DepartmentWidget extends StatelessWidget {
  const DepartmentWidget({
    super.key,
    required this.title,
    required this.isLightMode,
    required this.listDpt,
  });

  final String title;
  final bool isLightMode;
  final List<LinkWidget> listDpt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.chipBackground.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isLightMode
                  ? AppTheme.grey.withOpacity(0.8)
                  : AppTheme.chipBackground,
              width: 3),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
              iconColor: Colors.grey,
              collapsedIconColor: Colors.grey,
              title: Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isLightMode ? AppTheme.nearlyBlack : AppTheme.white),
              ),
              children: listDpt),
        ),
      ),
    );
  }
}

class LinkWidget extends StatelessWidget {
  const LinkWidget({
    super.key,
    required this.link,
    required this.title,
  });

  final String link;
  final String title;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () =>
          launchUrl(mode: LaunchMode.externalApplication, Uri.parse(link)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(
            Icons.open_in_new,
            size: 16,
            color: Colors.blue,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
