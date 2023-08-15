import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import '../../Components/card_1_widget.dart';
import '../../Core/app_theme.dart';
import '../../Core/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Components/action_button.dart';
import '../../Core/semester.dart';
import '../../Core/gpa_provider.dart';
import 'calc_sgpa_screen.dart.dart';

class CalcGpaScreen extends StatefulWidget {
  static String id = "CalcCgpa_Screen";

  const CalcGpaScreen({super.key});

  @override
  CalcGpaScreenState createState() => CalcGpaScreenState();
}

class CalcGpaScreenState extends State<CalcGpaScreen>
    with TickerProviderStateMixin {
  List<Semester> semesters = [];
  late SnackBar snackBar;
  bool _showUndoButton = false;
  late Semester deletedSemester;
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    _loadSemesters();
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  /// *********************************************************

  void addSemester(bool isLightMode) {
    var gpaProvider = Provider.of<GpaProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        String newSemesterName = '';
        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            'Add Semester',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black : Colors.white),
          ),
          content: TextField(
            style: TextStyle(color: isLightMode ? Colors.black : Colors.white),
            onChanged: (value) {
              newSemesterName = value;
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: 'Semester',
                labelStyle: TextStyle(
                    fontSize: 12,
                    color: isLightMode ? Colors.black : Colors.white)),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add',
                  style: TextStyle(
                      fontSize: 12,
                      color: isLightMode ? Colors.black : Colors.white)),
              onPressed: () {
                _saveSemesters();
                if (newSemesterName.isNotEmpty) {
                  setState(() {
                    Semester sem = Semester(newSemesterName, [], gpa: 0);
                    semesters = gpaProvider.addSemesterData(sem);
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteSemester(Semester semester) {
    setState(() {
      Provider.of<GpaProvider>(context, listen: false)
          .deleteSemesterData(semester);
      semesters.remove(semester);
      _saveSemesters();
      deletedSemester = semester;
      _showUndoButton = true;
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showUndoButton = false;
        });
      }
    });
  }

  void _undoDelete() {
    setState(() {
      Provider.of<GpaProvider>(context, listen: false)
          .addSemesterData(deletedSemester);
      _saveSemesters();
      _showUndoButton = false;
    });
  }

  /// *********************************************************
  void _saveSemesters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> semesterList = semesters
        .map((semester) => {
              'name': semester.name,
              'subjects': semester.subjects
                  .map((subject) => {
                        'name': subject.name,
                        'creditHours': subject.creditHours,
                        'expectedGrade': subject.expectedGrade,
                      })
                  .toList(),
              'gpa': semester.gpa,
            })
        .toList();
    prefs.setString('semesters', json.encode(semesterList));
    if (kDebugMode) {
      print('Semester saved:  $semesters');
    }
  }

  void _loadSemesters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? semesterJson = prefs.getString('semesters');
    if (semesterJson != null) {
      List<dynamic> semesterList = json.decode(semesterJson);
      setState(() {
        semesters = semesterList
            .map((semesterData) => Semester(
                  semesterData['name'],
                  (semesterData['subjects'] as List<dynamic>)
                      .map((subjectData) => Subject(
                            subjectData['name'],
                            subjectData['creditHours'],
                            subjectData['expectedGrade'],
                          ))
                      .toList(),
                  gpa: semesterData['gpa'],
                ))
            .toList();
        Provider.of<GpaProvider>(context, listen: false).loadData(semesters);
      });
    }
  }

  /// *********************************************************

  void resultDialog(bool isLightMode) {
    double gpa = calculateCGPA();
    Color gpaColor;
    if (gpa < 2.0) {
      gpaColor = Colors.red;
    } else if (gpa >= 2.0 && gpa < 3.0) {
      gpaColor = Colors.yellow;
    } else {
      gpaColor = Colors.green;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            'Expected CGPA',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black : Colors.white),
          ),
          content: Text(
            gpa.toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              color: gpaColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK',
                  style: TextStyle(
                      fontSize: 12,
                      color: isLightMode ? Colors.black : Colors.white)),
            ),
          ],
        );
      },
    );
  }

  double calculateCGPA() {
    double totalQualityPoints = 0;
    int totalCreditHours = 0;
    for (var semester in semesters) {
      double semesterSGPA = semester.gpa;
      int semesterCreditHours = 0;

      for (var subject in semester.subjects) {
        semesterCreditHours += subject.creditHours;
      }

      totalQualityPoints += (semesterSGPA * semesterCreditHours);
      totalCreditHours += semesterCreditHours;
    }
    if (totalQualityPoints == 0 || totalCreditHours == 0) {
      return 0;
    }
    double cgpa = totalQualityPoints / totalCreditHours;

    return cgpa;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isLightMode = themeProvider.isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    animationController?.forward();
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
          'GPA Calculator',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isLightMode ? Colors.black : Colors.white),
        ),
        actions: _showUndoButton
            ? [
                IconButton(
                    onPressed: _undoDelete,
                    icon: const Icon(
                      Icons.undo_rounded,
                      color: Colors.grey,
                    ))
              ]
            : null,
      ),
      body: semesters.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                    'No semester found. Add a semester using the " + " button.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.grey,
                    )),
              ),
            )
          : Consumer<GpaProvider>(
              builder: (context, gpaProvider, _) {
                return ListView.builder(
                  itemCount: semesters.length,
                  itemBuilder: (context, index) {
                    final semester = semesters[index];
                    String semesterTitle = semester.name;
                    double gpa = 0;
                    int totalCreditHours = 0;
                    if (gpaProvider.getSemester()[index].subjects.isNotEmpty) {
                      gpa = gpaProvider.getSemester()[index].gpa;
                      for (var subj
                          in gpaProvider.getSemester()[index].subjects) {
                        totalCreditHours += subj.creditHours;
                      }
                    }
                    return ListTile(
                        splashColor:
                            isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
                        onTap: () async {
                          var updatedGpa = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CalcSgpaScreen(
                                semester: semester,
                                index: index,
                              ),
                            ),
                          );
                          updatedGpa = gpaProvider.getSemester()[index].gpa;
                          if (updatedGpa != null) {
                            setState(() {
                              semesters = gpaProvider.getSemester();
                              _saveSemesters();
                            });
                          }
                        },
                        subtitle: SwipeableTile.card(
                          color: Colors.transparent,
                          shadow: const BoxShadow(
                            color: Colors.transparent,
                            blurRadius: 0,
                            offset: Offset(2, 2),
                          ),
                          horizontalPadding: 0,
                          verticalPadding: 0,
                          direction: SwipeDirection.horizontal,
                          onSwiped: (direction) {
                            setState(() {
                              _deleteSemester(semester);
                            });
                          },
                          backgroundBuilder: (context, direction, progress) {
                            return AnimatedBuilder(
                              animation: progress,
                              builder: (context, child) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  color: progress.value > 0.4
                                      ? const Color(0xFFed7474)
                                      : isLightMode
                                          ? AppTheme.white
                                          : AppTheme.nearlyBlack,
                                );
                              },
                            );
                          },
                          key: UniqueKey(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Card1Widget(
                              animation: Tween<double>(begin: 0.0, end: 1.0)
                                  .animate(CurvedAnimation(
                                      parent: animationController!,
                                      curve: const Interval((1 / 9) * 1, 1.0,
                                          curve: Curves.fastOutSlowIn))),
                              animationController: animationController!,
                              credits: totalCreditHours,
                              gpa: gpa,
                              name: semesterTitle,
                            ),
                          ),
                        ));
                  },
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ActionButton(
              func: () {
                addSemester(isLightMode);
              },
              icon: Icons.add,
              color: themeProvider.primaryColor,
            ),
            Expanded(child: Container()),
            ActionButton(
              func: () {
                resultDialog(isLightMode);
              },
              icon: Icons.calculate,
              color: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }
}
