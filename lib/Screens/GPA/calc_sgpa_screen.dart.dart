import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import '../../Components/action_button.dart';
import '../../Components/card_2_widget.dart';
import '../../Components/result_dialog.dart';
import '../../Core/semester.dart';
import '../../Core/app_theme.dart';
import '../../Core/gpa_provider.dart';
import '../../Core/theme_provider.dart';

class CalcSgpaScreen extends StatefulWidget {
  final Semester semester;
  final int index;

  const CalcSgpaScreen(
      {super.key, required this.semester, required this.index});

  @override
  CalcSgpaScreenState createState() => CalcSgpaScreenState();
}

class CalcSgpaScreenState extends State<CalcSgpaScreen> {
  List<int> creditHoursList = [1, 2, 3, 4, 5, 6];
  List<String> expectedGradesList = ['A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F'];
  List<Subject> subjects = [];
  late Subject _deletedSubject;
  bool isEditingTitle = false;
  final TextEditingController _titleController = TextEditingController();
  bool _showUndoButton = false;

  /// *********************************************************

  @override
  void initState() {
    subjects.addAll(widget.semester.subjects);
    super.initState();
  }

  void updateData() {
    var gpaProvider = Provider.of<GpaProvider>(context, listen: false);
    gpaProvider.updateSemesterData(
        Semester(widget.semester.name, subjects, gpa: calculateSGPA()),
        widget.index);
  }

  /// *********************************************************

  void editSubject(int index, bool isLightMode) {
    Subject subject = subjects[index];
    String subjectName = subject.name;
    int selectedCreditHours = subject.creditHours;
    String selectedExpectedGrade = subject.expectedGrade;
    bool isSnackBarVisible = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            'Edit Subject',
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
                  subjectName = value;
                },
                decoration: InputDecoration(
                  labelText: 'Subject Name',
                  labelStyle: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                ),
                controller: TextEditingController(text: subjectName),
              ),
              DropdownButtonFormField<int>(
                dropdownColor:
                    isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
                style:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
                value: selectedCreditHours,
                onChanged: (newValue) {
                  setState(() {
                    selectedCreditHours = newValue!;
                  });
                },
                items: creditHoursList.map((creditHours) {
                  return DropdownMenuItem<int>(
                    value: creditHours,
                    child: Text(
                      creditHours.toString(),
                      style: TextStyle(
                          color: isLightMode ? Colors.black : Colors.white),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Credit Hours',
                  labelStyle: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                ),
              ),
              DropdownButtonFormField<String>(
                dropdownColor:
                    isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
                style:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
                value: selectedExpectedGrade,
                onChanged: (newValue) {
                  setState(() {
                    selectedExpectedGrade = newValue!;
                  });
                },
                items: expectedGradesList.map((grade) {
                  return DropdownMenuItem<String>(
                    value: grade,
                    child: Text(
                      grade,
                      style: TextStyle(
                          color: isLightMode ? Colors.black : Colors.white),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Expected Grade',
                  labelStyle: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                ),
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
                if (subjectName.isNotEmpty) {
                  setState(() {
                    subjects[index] = Subject(
                      subjectName,
                      selectedCreditHours,
                      selectedExpectedGrade,
                    );
                    updateData();
                    selectedExpectedGrade = 'A';
                    selectedCreditHours = 0;
                  });
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
                        message: "Incorrect name",
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

  void _deleteSubject(Subject subject) {
    setState(() {
      subjects.remove(subject);
      updateData();
      _deletedSubject = subject;
      _showUndoButton = true;
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
      subjects.add(_deletedSubject);
      updateData();
      _showUndoButton = false;
    });
  }

  void _editTitle(bool isLightMode) {
    bool isSnackBarVisible = false;
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            backgroundColor:
                isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
            title: Text(
              'Edit Semester Title',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black : Colors.white,
              ),
            ),
            content: TextField(
              keyboardType: TextInputType.number,
              controller: _titleController,
              style:
                  TextStyle(color: isLightMode ? Colors.black : Colors.white),
              decoration: InputDecoration(
                labelText: 'Semester Title',
                labelStyle:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    isEditingTitle = false;
                  });
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text(
                  'Save',
                  style: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                ),
                onPressed: () {
                  if ((int.parse(_titleController.text) > 0) &&
                      int.parse(_titleController.text) < 9) {
                    setState(() {
                      widget.semester.name = _titleController.text;
                      isEditingTitle = false;
                      updateData();
                    });
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
                          message: "Incorrect name",
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
          ),
        );
      },
    );
  }

  void addSubject(bool isLightMode) {
    String selectedExpectedGrade = 'A';
    int selectedCreditHours = 1;
    String subjectName = '';
    bool isSnackBarVisible = false;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            'Add Subject',
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
                  setState(() {
                    subjectName = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Subject Name',
                  labelStyle: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                ),
              ),
              DropdownButtonFormField<int>(
                dropdownColor:
                    isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
                style:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
                value: selectedCreditHours,
                onChanged: (newValue) {
                  setState(() {
                    selectedCreditHours = newValue!;
                  });
                },
                items: creditHoursList.map((creditHours) {
                  return DropdownMenuItem<int>(
                    value: creditHours,
                    child: Text(
                      creditHours.toString(),
                      style: TextStyle(
                          color: isLightMode ? Colors.black : Colors.white),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Credit Hours',
                  labelStyle: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                ),
              ),
              DropdownButtonFormField<String>(
                dropdownColor:
                    isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
                style:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
                value: selectedExpectedGrade,
                onChanged: (newValue) {
                  setState(() {
                    selectedExpectedGrade = newValue!;
                  });
                },
                items: expectedGradesList.map((grade) {
                  return DropdownMenuItem<String>(
                    value: grade,
                    child: Text(
                      grade,
                      style: TextStyle(
                          color: isLightMode ? Colors.black : Colors.white),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Expected Grade',
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
                if (subjectName.isNotEmpty) {
                  setState(() {
                    subjects.add(
                      Subject(subjectName, selectedCreditHours,
                          selectedExpectedGrade),
                    );
                    updateData();
                  });
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
                        title: '',
                        message: "Incorrect name",
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
    double gpa = calculateSGPA();
    Color gpaColor;
    if (gpa < 2.0) {
      gpaColor = Colors.red;
    } else if (gpa >= 2.0 && gpa < 3.0) {
      gpaColor = Colors.orange;
    } else if (gpa < 4) {
      gpaColor = Colors.green;
    } else {
      gpaColor = AppTheme.ace;
    }
    ResultDialog().showResult(
        title: 'Expected SGPA',
        description: gpa.toStringAsFixed(2),
        color: gpaColor,
        isLightMode: isLightMode,
        context: context);
  }

  double calculateSGPA() {
    double totalGradePoints = 0;
    int totalCreditHours = 0;

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

      double subjectGradePoints = gradePoints * subject.creditHours;
      totalGradePoints += subjectGradePoints;
      totalCreditHours += subject.creditHours;
    }
    if (totalGradePoints == 0 || totalCreditHours == 0) {
      return 0;
    }

    double sgpa = totalGradePoints / totalCreditHours;
    return sgpa;
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
        title: GestureDetector(
          onTap: () {
            setState(() {
              isEditingTitle = true;
            });
            _editTitle(isLightMode);
          },
          child: isEditingTitle
              ? const SizedBox.shrink()
              : Text(
                  'Semester ${widget.semester.name}',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isLightMode ? Colors.black : Colors.white),
                ),
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
      body: subjects.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No subject found. Add a subject using the " + " button.',
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
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                String grade = subject.expectedGrade;
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
                        _deleteSubject(subject);
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
                        child: Card2Widget(
                          credits: subject.creditHours,
                          grade: grade,
                          name: subject.name,
                          semesterIndex: widget.index,
                          subjectIndex: index,
                          gradeDowngrade: () {
                            setState(() {
                              grade = _gradeDowngrade(grade);
                              subjects[index].expectedGrade = grade;
                              updateData();
                            });
                          },
                          gradeUpgrade: () {
                            setState(() {
                              grade = _gradeUpgrade(grade);
                              subjects[index].expectedGrade = grade;
                              updateData();
                            });
                          },
                          editFunction: () {
                            editSubject(index, isLightMode);
                          },
                        ),
                      ),
                    ));
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ActionButton(
              func: () {
                addSubject(isLightMode);
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
