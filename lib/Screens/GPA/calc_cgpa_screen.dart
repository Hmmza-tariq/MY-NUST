import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import '../../Components/action_button.dart';
import '../../Components/card_1_widget.dart';
import '../../Components/result_dialog.dart';
import '../../Core/app_theme.dart';
import '../../Core/theme_provider.dart';

class CalcCgpaScreen extends StatefulWidget {
  const CalcCgpaScreen({super.key});

  @override
  CalcCgpaScreenState createState() => CalcCgpaScreenState();
}

class CalcCgpaScreenState extends State<CalcCgpaScreen>
    with TickerProviderStateMixin {
  List<Sem> semesters = [];
  late Sem _deletedSemester;
  bool _showUndoButton = false;
  AnimationController? animationController;

  /// *********************************************************

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

  void _editSemester(int index, bool isLightMode) {
    Sem semester = semesters[index];
    int semesterNo = semester.name;
    int credits = semester.credits;
    double sgpa = semester.sgpa;
    bool isSnackBarVisible = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            'Edit Semester',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black : Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
                onChanged: (value) {
                  semesterNo = int.parse(value);
                },
                decoration: InputDecoration(
                  labelText: 'Semester no',
                  labelStyle: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                ),
                controller: TextEditingController(text: semesterNo.toString()),
              ),
              TextField(
                style:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
                onChanged: (value) {
                  sgpa = double.parse(value);
                },
                decoration: InputDecoration(
                  labelText: 'SGPA',
                  labelStyle: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                ),
                controller: TextEditingController(text: sgpa.toString()),
              ),
              TextField(
                style:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
                onChanged: (value) {
                  credits = int.parse(value);
                },
                decoration: InputDecoration(
                  labelText: 'Credit hours',
                  labelStyle: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                ),
                controller: TextEditingController(text: credits.toString()),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Save',
                  style: TextStyle(
                      fontSize: 12,
                      color: isLightMode ? Colors.black : Colors.white)),
              onPressed: () {
                if (semesterNo <= 8 &&
                    semesterNo > 0 &&
                    sgpa <= 4 &&
                    sgpa > 0 &&
                    credits <= 30 &&
                    credits > 0) {
                  setState(() {
                    semesters[index] = Sem(
                      semesterNo,
                      sgpa,
                      credits,
                    );
                  });
                  _saveSemesters();
                  Navigator.pop(context);
                } else {
                  if (!isSnackBarVisible) {
                    setState(() {
                      isSnackBarVisible = true;
                    });
                    final snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Error',
                        message: "Incorrect Data",
                        contentType: ContentType.warning,
                      ),
                    );

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(snackBar).closed.then((_) {
                        setState(() {
                          isSnackBarVisible = false;
                        });
                      });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteSemester(Sem semester) {
    setState(() {
      semesters.remove(semester);
      _deletedSemester = semester;
      _showUndoButton = true;
      _saveSemesters();
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showUndoButton = false;
        });
      }
    });
  }

  void _undoDelete() {
    setState(() {
      semesters.add(_deletedSemester);
      _showUndoButton = false;
      _saveSemesters();
    });
  }

  void addSemester(bool isLightMode) {
    double sgpa = 0.0;
    int credits = 0;
    int semesterNo = 1;
    bool isSnackBarVisible = false;
    showDialog(
      context: context,
      builder: (context) {
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                style:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
                onChanged: (value) {
                  setState(() {
                    semesterNo = int.parse(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Semester No',
                  labelStyle: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                ),
              ),
              TextField(
                keyboardType: TextInputType.number,
                style:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
                onChanged: (value) {
                  setState(() {
                    sgpa = double.parse(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'SGPA',
                  labelStyle: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                ),
              ),
              TextField(
                keyboardType: TextInputType.number,
                style:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
                onChanged: (value) {
                  setState(() {
                    credits = int.parse(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Credit Hours',
                  labelStyle: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add',
                  style: TextStyle(
                      fontSize: 12,
                      color: isLightMode ? Colors.black : Colors.white)),
              onPressed: () {
                if (semesterNo <= 8 &&
                    semesterNo > 0 &&
                    sgpa <= 4 &&
                    sgpa > 0 &&
                    credits <= 30 &&
                    credits > 0) {
                  setState(() {
                    semesters.add(
                      Sem(semesterNo, sgpa, credits),
                    );
                  });
                  _saveSemesters();
                  Navigator.pop(context);
                } else {
                  if (!isSnackBarVisible) {
                    setState(() {
                      isSnackBarVisible = true;
                    });
                    final snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Error',
                        message: "Incorrect Data",
                        contentType: ContentType.warning,
                      ),
                    );

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(snackBar).closed.then((_) {
                        setState(() {
                          isSnackBarVisible = false;
                        });
                      });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// *********************************************************

  void resultDialog(bool isLightMode) {
    double cgpa = calculateCGPA();
    Color gpaColor;
    if (cgpa < 2.0) {
      gpaColor = Colors.red;
    } else if (cgpa >= 2.0 && cgpa < 3.0) {
      gpaColor = Colors.orange;
    } else if (cgpa < 4) {
      gpaColor = Colors.green;
    } else {
      gpaColor = AppTheme.ace;
    }

    int credits = 0;
    for (Sem s in semesters) {
      credits += s.credits;
    }
    ResultDialog().showResult(
        context: context,
        isLightMode: isLightMode,
        color: gpaColor,
        title1: 'Semesters',
        description1: semesters.length.toDouble(),
        title2: 'Credit Hours',
        description2: credits.toDouble(),
        marksObtained: cgpa.toDouble(),
        marksTotal: (4).toDouble(),
        type: 'CGPA');
  }

  double calculateCGPA() {
    double totalQualityPoints = 0;
    int totalCreditHours = 0;
    for (var semester in semesters) {
      double semesterSGPA = semester.sgpa;
      int semesterCreditHours = semester.credits;

      totalQualityPoints += (semesterSGPA * semesterCreditHours);
      totalCreditHours += semesterCreditHours;
    }
    if (totalQualityPoints == 0 || totalCreditHours == 0) {
      return 0;
    }
    double cgpa = totalQualityPoints / totalCreditHours;

    return cgpa;
  }

  /// *********************************************************
  Future<void> _loadSemesters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? semestersJson = prefs.getStringList('semesters2');

    if (semestersJson != null) {
      setState(() {
        semesters = semestersJson.map((semesterJson) {
          Map<String, dynamic> semesterMap = Map<String, dynamic>.from(
            json.decode(semesterJson),
          );
          return Sem(
            semesterMap['name'],
            semesterMap['sgpa'],
            semesterMap['credits'],
          );
        }).toList();
      });
    }
  }

  Future<void> _saveSemesters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> semestersJson = semesters.map((semester) {
      Map<String, dynamic> semesterMap = {
        'name': semester.name,
        'sgpa': semester.sgpa,
        'credits': semester.credits,
      };
      return json.encode(semesterMap);
    }).toList();

    prefs.setStringList('semesters2', semestersJson);
  }

  /// *********************************************************
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
          'CGPA Calculator',
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
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: semesters.length,
              itemBuilder: (context, index) {
                return ListTile(
                  splashColor:
                      isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
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
                        _deleteSemester(semesters[index]);
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
                          child: SwipeableTile.card(
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
                                _deleteSemester(semesters[index]);
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: GestureDetector(
                                onTap: () => _editSemester(index, isLightMode),
                                child: Card1Widget(
                                  animation: Tween<double>(begin: 0.0, end: 1.0)
                                      .animate(CurvedAnimation(
                                          parent: animationController!,
                                          curve: const Interval(
                                              (1 / 9) * 1, 1.0,
                                              curve: Curves.fastOutSlowIn))),
                                  animationController: animationController!,
                                  credits: semesters[index].credits,
                                  gpa: semesters[index].sgpa,
                                  name: semesters[index].name.toString(),
                                ),
                              ),
                            ),
                          ))),
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

class Sem {
  int name = 1;
  double sgpa = 0;
  int credits = 0;

  Sem(this.name, this.sgpa, this.credits);
}
