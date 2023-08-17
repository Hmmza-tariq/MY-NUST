import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Components/hex_color.dart';
import '../Core/app_theme.dart';
import '../Core/theme_provider.dart';
import 'brick.dart';

class Card2Widget extends StatefulWidget {
  const Card2Widget(
      {Key? key,
      required this.name,
      required this.credits,
      required this.grade,
      required this.semesterIndex,
      required this.subjectIndex,
      required this.gradeUpgrade,
      required this.gradeDowngrade,
      required this.editFunction})
      : super(key: key);

  final String name;
  final int credits;
  final int semesterIndex;
  final int subjectIndex;
  final String grade;
  final Function gradeUpgrade;
  final Function gradeDowngrade;
  final Function editFunction;
  @override
  Card2WidgetState createState() => Card2WidgetState();
}

class Card2WidgetState extends State<Card2Widget>
    with TickerProviderStateMixin {
  String grade = 'X';

  @override
  void initState() {
    grade = widget.grade;
    super.initState();
  }

  @override
  void didUpdateWidget(Card2Widget oldWidget) {
    if (oldWidget.grade != widget.grade) {
      grade = widget.grade;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    bool isLightMode = Provider.of<ThemeProvider>(context).isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Container(
        decoration: BoxDecoration(
          color: isLightMode ? AppTheme.nearlyWhite : AppTheme.grey,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
              topRight: Radius.circular(68.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: AppTheme.grey.withOpacity(0.2),
                offset: const Offset(1.1, 1.1),
                blurRadius: 10.0),
          ],
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.editFunction(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Container(
                            height: 48,
                            width: 2,
                            decoration: BoxDecoration(
                              color: HexColor('#87A0E5').withOpacity(0.5),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, bottom: 2),
                                  child: Text(
                                    'Subject',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      letterSpacing: -0.1,
                                      color: isLightMode
                                          ? AppTheme.grey.withOpacity(0.7)
                                          : AppTheme.chipBackground
                                              .withOpacity(0.7),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, bottom: 3),
                                  child: SizedBox(
                                    width: 120,
                                    child: Text(
                                      widget.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                        color: isLightMode
                                            ? AppTheme.darkText
                                            : AppTheme.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            height: 48,
                            width: 2,
                            decoration: BoxDecoration(
                              color: HexColor('#F56E98').withOpacity(0.5),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, bottom: 2),
                                  child: Text(
                                    'Credit Hours',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      letterSpacing: -0.1,
                                      color: isLightMode
                                          ? AppTheme.grey.withOpacity(0.7)
                                          : AppTheme.chipBackground
                                              .withOpacity(0.7),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, bottom: 3),
                                  child: Text(
                                    '${widget.credits}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: isLightMode
                                          ? AppTheme.darkText
                                          : AppTheme.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 34,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => setState(() {
                        grade = _gradeUpgrade(grade);
                        widget.gradeUpgrade();
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.nearlyWhite,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: AppTheme.darkerText.withOpacity(0.4),
                                offset: const Offset(4.0, 4.0),
                                blurRadius: 8.0),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.add,
                            color: AppTheme.grey,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        grade = _gradeDowngrade(grade);
                        widget.gradeDowngrade();
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.nearlyWhite,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: AppTheme.darkerText.withOpacity(0.4),
                                offset: const Offset(4.0, 4.0),
                                blurRadius: 8.0),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.remove,
                            color: AppTheme.grey,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 14, top: 6),
                child: WaveView(
                  grade: grade,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _gradeUpgrade(String grade) {
    switch (grade) {
      case 'B+':
        grade = 'A';
        break;
      case 'B':
        grade = 'B+';
        break;
      case 'C+':
        grade = 'B';
        break;
      case 'C':
        grade = 'C+';
        break;
      case 'D+':
        grade = 'C';
        break;
      case 'D':
        grade = 'D+';
        break;
      case 'F':
        grade = 'D';
        break;
      default:
        break;
    }
    return grade;
  }

  String _gradeDowngrade(String grade) {
    switch (grade) {
      case 'A':
        grade = 'B+';
        break;
      case 'B+':
        grade = 'B';
        break;
      case 'B':
        grade = 'C+';
        break;
      case 'C+':
        grade = 'C';
        break;
      case 'C':
        grade = 'D+';
        break;
      case 'D+':
        grade = 'D';
        break;
      case 'D':
        grade = 'F';
        break;
      default:
        break;
    }
    return grade;
  }
}
