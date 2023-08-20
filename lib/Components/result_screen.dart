import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mynust/Core/app_theme.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';

import '../Core/semester.dart';
import 'action_button.dart';

class ResultScreen extends StatefulWidget {
  final double marksObtained;
  final double marksTotal;
  final String title1;
  final double description1;
  final String title2;
  final double description2;
  final String type;
  final Color color;
  final bool isSGPA;
  final bool isCGPA;
  final bool isGPA;
  final bool isAbsolutes;
  final bool isAggregate;
  final bool isLightMode;
  final List<Semester> semesters;
  final List<Sem> sems;
  final List<Subject> subjects;

  const ResultScreen(
      {Key? key,
      required this.marksObtained,
      required this.description1,
      required this.description2,
      required this.marksTotal,
      required this.title1,
      required this.title2,
      required this.type,
      required this.color,
      required this.isSGPA,
      required this.isCGPA,
      required this.isGPA,
      required this.isAbsolutes,
      required this.isAggregate,
      required this.semesters,
      required this.sems,
      required this.subjects,
      required this.isLightMode})
      : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final GlobalKey previewContainer = GlobalKey();
  bool isLightMode = false;

  @override
  void initState() {
    super.initState();
    isLightMode = widget.isLightMode;
  }

  Future<bool> captureScreenShot(String type) async {
    await ShareFilesAndScreenshotWidgets().shareScreenshot(
        previewContainer, 1000, "Logo", "result.png", "image/png",
        text:
            "Hey! Check this out. I calculated my expected $type using 'My NUST' app.");
    return true;
  }

  @override
  Widget build(BuildContext context) {
    int items = (widget.isGPA)
        ? widget.semesters.length
        : (widget.isCGPA)
            ? widget.sems.length
            : (widget.isSGPA)
                ? widget.subjects.length
                : 0;
    double defaultPadding = (24 / items);
    if (items < 5) defaultPadding = 16;
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
              'Calculated ${widget.type}',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isLightMode ? Colors.black : Colors.white),
            ),
            actions: [
              IconButton(
                  onPressed: () => setState(() {
                        isLightMode = !isLightMode;
                      }),
                  icon: Icon(
                    isLightMode
                        ? Icons.light_mode_rounded
                        : Icons.nightlight_outlined,
                    color: Colors.grey,
                  ))
            ]),
        body: RepaintBoundary(
          key: previewContainer,
          child: Container(
            padding: EdgeInsets.only(top: defaultPadding, left: 16, right: 16),
            decoration: BoxDecoration(
              color:
                  isLightMode == true ? AppTheme.white : AppTheme.nearlyBlack,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // SizedBox(height: defaultPadding),
                Stack(
                  alignment: AlignmentDirectional.topStart,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${widget.type}:',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isLightMode
                                        ? Colors.black
                                        : Colors.white),
                              ),
                              SizedBox(
                                height: (80 - (defaultPadding / 3)) * 2,
                              ),
                              Text(
                                (widget.isGPA)
                                    ? "${widget.semesters.length} Semesters"
                                    : (widget.isCGPA)
                                        ? "${widget.sems.length} Semesters"
                                        : (widget.isSGPA)
                                            ? "${widget.subjects.length} Subjects"
                                            : '',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isLightMode
                                        ? Colors.black
                                        : Colors.white),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                              border: Border.all(
                                  width: 2,
                                  color: isLightMode
                                      ? Colors.black.withOpacity(.4)
                                      : Colors.white.withOpacity(.4)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                'MY NUST',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isLightMode
                                        ? Colors.black.withOpacity(.4)
                                        : Colors.white.withOpacity(.4)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chart(
                      marksObtained: widget.marksObtained,
                      marksTotal: widget.marksTotal,
                      isLightMode: isLightMode,
                      defaultPadding: defaultPadding,
                      isAbsolutes: widget.isAbsolutes,
                      isAggregate: widget.isAggregate,
                      isCGPA: widget.isCGPA,
                      isGPA: widget.isGPA,
                      isSGPA: widget.isSGPA,
                      semesters: widget.semesters,
                      sems: widget.sems,
                      subjects: widget.subjects,
                      color: widget.color,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                (widget.isAbsolutes || widget.isAggregate)
                    ? Container()
                    : Expanded(
                        child: ListView.builder(
                          itemCount: items,
                          itemBuilder: (context, index) {
                            return ListTile(
                                splashColor: isLightMode
                                    ? AppTheme.white
                                    : AppTheme.nearlyBlack,
                                subtitle: DetailCard(
                                  title: (widget.isSGPA)
                                      ? widget.subjects[index].name
                                      : "Semester ${index + 1}",
                                  trailing: (widget.isSGPA)
                                      ? widget.subjects[index].expectedGrade
                                      : (widget.isCGPA)
                                          ? widget.sems[index].sgpa
                                              .toStringAsFixed(2)
                                          : widget.semesters[index].gpa
                                              .toStringAsFixed(2),
                                  numOfFiles: (widget.isSGPA)
                                      ? widget.subjects[index].creditHours
                                      : (widget.isCGPA)
                                          ? widget.sems[index].credits
                                          : widget.semesters[index].credits,
                                  isLightMode: isLightMode,
                                  defaultPadding: defaultPadding,
                                ));
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
        floatingActionButton: ActionButton(
          color: Colors.green,
          func: () => captureScreenShot(widget.type),
          icon: Icons.share,
        ));
  }
}

class Chart extends StatelessWidget {
  const Chart(
      {Key? key,
      required this.marksObtained,
      required this.marksTotal,
      required this.isLightMode,
      required this.defaultPadding,
      required this.isSGPA,
      required this.isCGPA,
      required this.isGPA,
      required this.isAbsolutes,
      required this.isAggregate,
      required this.semesters,
      required this.sems,
      required this.subjects,
      required this.color})
      : super(key: key);
  final double marksObtained;
  final double marksTotal;
  final double defaultPadding;
  final bool isLightMode;
  final Color color;
  final bool isSGPA;
  final bool isCGPA;
  final bool isGPA;
  final bool isAbsolutes;
  final bool isAggregate;
  final List<Semester> semesters;
  final List<Sem> sems;
  final List<Subject> subjects;

  Color getColorForIndex(int index) {
    List<Color> colorList = [
      Colors.green,
      Colors.red,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];

    return colorList[index % colorList.length];
  }

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> pieChartSectionData = [];
    double radius = 13;
    int index = 0;
    double left = 0;
    if (isCGPA) {
      for (var sem in sems) {
        left += (4 - sem.sgpa);
        pieChartSectionData.add(PieChartSectionData(
            color: getColorForIndex(index++),
            value: sem.sgpa,
            radius: radius += 2,
            showTitle: true,
            titlePositionPercentageOffset: 2,
            titleStyle:
                TextStyle(color: isLightMode ? Colors.black : Colors.white)));
      }
      pieChartSectionData.add(PieChartSectionData(
          color: AppTheme.grey.withOpacity(.2),
          value: left,
          radius: radius += 2,
          showTitle: false));
    } else if (isGPA) {
      for (var sem in semesters) {
        left += (4 - sem.gpa);
        pieChartSectionData.add(PieChartSectionData(
            color: getColorForIndex(index++),
            value: double.parse(sem.gpa.toStringAsFixed(2)),
            radius: radius += 2,
            showTitle: true,
            titlePositionPercentageOffset: 2,
            titleStyle:
                TextStyle(color: isLightMode ? Colors.black : Colors.white)));
      }
      pieChartSectionData.add(PieChartSectionData(
          color: AppTheme.grey.withOpacity(.2),
          value: left,
          radius: radius += 2,
          showTitle: false));
    } else if (isSGPA) {
      for (var subject in subjects) {
        double gradePoints;
        switch (subject.expectedGrade) {
          case 'A':
            gradePoints = 4.0;
            break;
          case 'B+':
            gradePoints = 3.5;
            break;
          case 'B':
            gradePoints = 3.0;
            break;
          case 'C+':
            gradePoints = 2.5;
            break;
          case 'C':
            gradePoints = 2.0;
            break;
          case 'D+':
            gradePoints = 1.5;
            break;
          case 'D':
            gradePoints = 1.0;
            break;
          case 'F':
            gradePoints = 0.0;
            break;
          default:
            gradePoints = 0.0;
            break;
        }
        left += (4 - gradePoints);
        pieChartSectionData.add(PieChartSectionData(
            color: getColorForIndex(index++),
            value: gradePoints,
            radius: radius += 2,
            showTitle: true,
            titlePositionPercentageOffset: 2,
            titleStyle:
                TextStyle(color: isLightMode ? Colors.black : Colors.white)));
      }
      pieChartSectionData.add(PieChartSectionData(
          color: AppTheme.grey.withOpacity(.2),
          value: left,
          radius: radius += 2,
          showTitle: false));
    } else {
      pieChartSectionData = [
        PieChartSectionData(
          color: AppTheme.grey,
          value: 25,
          showTitle: false,
          radius: 25,
        ),
        PieChartSectionData(
          color: const Color(0xFF26E5FF),
          value: 20,
          showTitle: false,
          radius: 22,
        ),
        PieChartSectionData(
          color: const Color(0xFFFFCF26),
          value: 10,
          showTitle: false,
          radius: 19,
        ),
        PieChartSectionData(
          color: const Color(0xFFEE2727),
          value: 15,
          showTitle: false,
          radius: 16,
        ),
        PieChartSectionData(
          color: AppTheme.grey.withOpacity(0.1),
          value: 25,
          showTitle: false,
          radius: 13,
        ),
      ];
    }
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 70 - (defaultPadding / 3),
              startDegreeOffset: -90,
              sections: pieChartSectionData,
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: defaultPadding),
                Text(
                  marksObtained.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold, fontSize: 30, color: color),
                ),
                Text(
                  'out of ${marksTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailCard extends StatelessWidget {
  const DetailCard({
    Key? key,
    required this.title,
    required this.trailing,
    required this.numOfFiles,
    required this.isLightMode,
    required this.defaultPadding,
  }) : super(key: key);

  final String title, trailing;
  final int numOfFiles;
  final double defaultPadding;
  final bool isLightMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0, bottom: 0),
      padding: EdgeInsets.symmetric(
          horizontal: defaultPadding, vertical: defaultPadding / 2),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: AppTheme.grey.withOpacity(0.8)),
        borderRadius: BorderRadius.all(
          Radius.circular(defaultPadding),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 30,
            width: 30,
            child: Image.asset('assets/images/fire.png'),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: isLightMode ? Colors.black : Colors.white),
                  ),
                  Text(
                    "$numOfFiles Credits",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: isLightMode ? Colors.black : Colors.white),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              trailing,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: isLightMode ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w700),
            ),
          )
        ],
      ),
    );
  }
}
