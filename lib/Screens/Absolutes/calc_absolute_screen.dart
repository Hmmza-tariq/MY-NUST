import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:info_popup/info_popup.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import '../../Components/action_button.dart';
import '../../Core/assessments.dart';
import '../../Core/app_theme.dart';
import '../../Core/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalcAbsoluteScreen extends StatefulWidget {
  static const String id = "CalcAbsolute_Screen";

  const CalcAbsoluteScreen({Key? key}) : super(key: key);

  @override
  CalcAbsoluteScreenState createState() => CalcAbsoluteScreenState();
}

class CalcAbsoluteScreenState extends State<CalcAbsoluteScreen> {
  List<Assessment> lectureAssessments = [];
  List<Assessment> labAssessments = [];
  late Assessment deletedAssessment;
  double lectureWeightage = 67;
  double labWeightage = 33;
  double obtainedAbsolutes = 0;
  double lectureAbsolutes = 0;
  double labAbsolutes = 0;
  bool _showUndoButton = false;
  bool error = false;
  bool _isSnackBarVisible = false;
  List<TextEditingController> _obtainedMarksControllers = [
    TextEditingController()
  ];
  List<TextEditingController> _totalMarksControllers = [
    TextEditingController()
  ];

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadAssessments() async {
    List<Assessment> loadedLectureAssessments = [];
    List<Assessment> loadedLabAssessments = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lectureAssessmentJson = prefs.getString('lectureAssessments');
    String? labAssessmentJson = prefs.getString('labAssessments');
    if (lectureAssessmentJson != null) {
      List<dynamic> lectureAssessmentList = json.decode(lectureAssessmentJson);
      loadedLectureAssessments = lectureAssessmentList
          .map((assessmentData) => Assessment(
                assessmentData['name'],
                assessmentData['weightage'],
                assessmentData['obtainedMarks'],
                assessmentData['totalMarks'],
                section: assessmentData['section'],
              ))
          .toList();
    }
    if (labAssessmentJson != null) {
      List<dynamic> labAssessmentList = json.decode(labAssessmentJson);
      loadedLabAssessments = labAssessmentList
          .map((assessmentData) => Assessment(
                assessmentData['name'],
                assessmentData['weightage'],
                assessmentData['obtainedMarks'],
                assessmentData['totalMarks'],
                section: assessmentData['section'],
              ))
          .toList();
    }
    if (loadedLectureAssessments.isEmpty) {
      loadedLectureAssessments = [
        Assessment('Quiz', 15, 10, 10, section: 'Lecture'),
        Assessment('Assignment', 15, 10, 10, section: 'Lecture'),
        Assessment('Mid', 30, 100, 100, section: 'Lecture'),
        Assessment('Final', 40, 100, 100, section: 'Lecture'),
      ];
    }
    if (loadedLabAssessments.isEmpty) {
      loadedLabAssessments = [
        Assessment('Lab tasks', 30, 100, 100, section: 'Lab'),
        Assessment('Lab mid', 30, 100, 100, section: 'Lab'),
        Assessment('Lab final', 40, 100, 100, section: 'Lab'),
      ];
    }
    setState(() {
      lectureAssessments = loadedLectureAssessments;
      labAssessments = loadedLabAssessments;
    });
    updateAbsolutes();
  }

  void _saveAssessments() async {
    if (!error) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> lectureAssessmentList = lectureAssessments
          .map((assessment) => {
                'name': assessment.name,
                'weightage': assessment.weightage,
                'obtainedMarks': assessment.obtainedMarks,
                'totalMarks': assessment.totalMarks,
                'section': assessment.section,
              })
          .toList();
      prefs.setString('lectureAssessments', json.encode(lectureAssessmentList));

      List<Map<String, dynamic>> labAssessmentList = labAssessments
          .map((assessment) => {
                'name': assessment.name,
                'weightage': assessment.weightage,
                'obtainedMarks': assessment.obtainedMarks,
                'totalMarks': assessment.totalMarks,
                'section': assessment.section,
              })
          .toList();
      prefs.setString('labAssessments', json.encode(labAssessmentList));
      // Provider.of<AssessmentProvider>(context, listen: false)
      //     .setAssessments(lectureAssessments);
    }
  }

  void updateAbsolutes() {
    double totalObtainedMarksLc = 0;
    double totalMarksLc = 0;
    double totalWeightageLc = 0;
    double totalObtainedMarksLb = 0;
    double totalMarksLb = 0;
    double totalWeightageLb = 0;

    for (var assessment in lectureAssessments) {
      totalObtainedMarksLc += assessment.obtainedMarks;
      totalWeightageLc += assessment.weightage;
      totalMarksLc += assessment.totalMarks;
    }
    for (var assessment in labAssessments) {
      totalObtainedMarksLb += assessment.obtainedMarks;
      totalWeightageLb += assessment.weightage;
      totalMarksLb += assessment.totalMarks;
    }

    setState(() {
      lectureAbsolutes =
          (totalObtainedMarksLc / totalMarksLc) * totalWeightageLc;
      labAbsolutes = (totalObtainedMarksLb / totalMarksLb) * totalWeightageLb;
      obtainedAbsolutes = (lectureAbsolutes + labAbsolutes) / 2;
    });
  }

  double calculateAbsoluteMarks() {
    double lectureAbsoluteMarks = lectureAbsolutes * (lectureWeightage / 100);
    double labAbsoluteMarks = labAbsolutes * (labWeightage / 100);

    double absoluteMarks = lectureAbsoluteMarks + labAbsoluteMarks;
    return absoluteMarks;
  }

  void _editWeightage(double weightage, String section, bool isLightMode) {
    double newWeightage = weightage;
    HapticFeedback.vibrate();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            'Edit $section Weightage',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black : Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                style: TextStyle(
                    fontSize: 14,
                    color: isLightMode ? Colors.black : Colors.white),
                initialValue: weightage.toStringAsFixed(1),
                onChanged: (value) {
                  newWeightage = double.tryParse(value) ?? weightage;
                },
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                    labelText: 'Weightage',
                    labelStyle: TextStyle(
                        fontSize: 14,
                        color: isLightMode ? Colors.black : Colors.white)),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel',
                  style: TextStyle(
                      fontSize: 12,
                      color: isLightMode ? Colors.black : Colors.white)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (newWeightage >= 0 && newWeightage <= 100) {
                    if (section == 'Lecture') {
                      lectureWeightage = newWeightage;
                      labWeightage = 100 - lectureWeightage;
                    } else if (section == 'Lab') {
                      labWeightage = newWeightage;
                      lectureWeightage = 100 - labWeightage;
                    }
                    _saveAssessments();
                  }
                  Navigator.pop(context);
                });
              },
              child: Text('Save',
                  style: TextStyle(
                      fontSize: 12,
                      color: isLightMode ? Colors.black : Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void resultDialog(bool isLightMode) {
    updateAbsolutes();
    double absoluteMarks = calculateAbsoluteMarks();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.only(top: 22),
          iconPadding: const EdgeInsets.all(0),
          buttonPadding: const EdgeInsets.all(4),
          insetPadding: const EdgeInsets.all(0),
          actionsPadding: const EdgeInsets.all(4),
          contentPadding: const EdgeInsets.all(4),
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            error ? '' : 'Absolute Marks',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black : Colors.white),
          ),
          content: Text(
            error ? 'ERROR!' : absoluteMarks.toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: error
                  ? Colors.red
                  : absoluteMarks < 33
                      ? Colors.red
                      : (absoluteMarks >= 33 && absoluteMarks < 60)
                          ? Colors.orange
                          : (absoluteMarks < 90)
                              ? Colors.green
                              : AppTheme.ace,
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

  void _editAssessment(Assessment assessment, int index, bool isLightMode) {
    TextEditingController nameController =
        TextEditingController(text: assessment.name);
    TextEditingController weightageController =
        TextEditingController(text: assessment.weightage.toString());
    TextEditingController obtainedMarksController =
        TextEditingController(text: assessment.obtainedMarks.toString());
    TextEditingController totalMarksController =
        TextEditingController(text: assessment.totalMarks.toString());

    showDialog(
      context: context,
      builder: (context) {
        String? editedAssessmentName = assessment.name;
        double? editedAssessmentWeightage = assessment.weightage;
        double? editedAssessmentObtainedMarks = assessment.obtainedMarks;
        double? editedAssessmentTotalMarks = assessment.totalMarks;

        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            'Edit Assessment',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black : Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  style: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                  controller: nameController,
                  onChanged: (value) {
                    setState(() {
                      editedAssessmentName = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Assessment Name',
                    labelStyle: TextStyle(
                        color: isLightMode ? Colors.black : Colors.white),
                  ),
                ),
                TextFormField(
                  style: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                  controller: weightageController,
                  onChanged: (value) {
                    setState(() {
                      editedAssessmentWeightage = double.tryParse(value);
                    });
                  },
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Weightage',
                    labelStyle: TextStyle(
                        color: isLightMode ? Colors.black : Colors.white),
                  ),
                ),
                TextFormField(
                  style: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                  controller: obtainedMarksController,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      editedAssessmentObtainedMarks = double.tryParse(value);
                    } else {
                      editedAssessmentObtainedMarks = null;
                    }
                  },
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Obtained Marks',
                    labelStyle: TextStyle(
                        color: isLightMode ? Colors.black : Colors.white),
                  ),
                ),
                TextFormField(
                  style: TextStyle(
                      color: isLightMode ? Colors.black : Colors.white),
                  controller: totalMarksController,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      editedAssessmentTotalMarks = double.tryParse(value);
                    } else {
                      editedAssessmentTotalMarks = null;
                    }
                  },
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Total Marks',
                    labelStyle: TextStyle(
                        color: isLightMode ? Colors.black : Colors.white),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(
                      fontSize: 12,
                      color: isLightMode ? Colors.black : Colors.white)),
              onPressed: () {
                checkError(assessment.section);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Save',
                  style: TextStyle(
                      fontSize: 12,
                      color: isLightMode ? Colors.black : Colors.white)),
              onPressed: () {
                if (editedAssessmentWeightage != null &&
                    editedAssessmentObtainedMarks != null &&
                    editedAssessmentTotalMarks != null) {
                  if (editedAssessmentObtainedMarks! >
                      editedAssessmentTotalMarks!) {
                    if (!_isSnackBarVisible) {
                      setState(() {
                        _isSnackBarVisible = true;
                      });
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Obtained marks cannot be more than total marks.'),
                              backgroundColor: Colors.red,
                            ),
                          )
                          .closed
                          .then((_) {
                        setState(() {
                          _isSnackBarVisible = false;
                        });
                      });
                    }
                  } else {
                    setState(() {
                      if (assessment.section == 'Lecture') {
                        lectureAssessments[index] = Assessment(
                          editedAssessmentName!,
                          editedAssessmentWeightage!,
                          editedAssessmentObtainedMarks!,
                          editedAssessmentTotalMarks!,
                          section: assessment.section,
                        );
                      } else {
                        labAssessments[index] = Assessment(
                          editedAssessmentName!,
                          editedAssessmentWeightage!,
                          editedAssessmentObtainedMarks!,
                          editedAssessmentTotalMarks!,
                          section: assessment.section,
                        );
                      }
                      checkError(assessment.section);
                      _saveAssessments();
                      Navigator.pop(context);
                    });
                  }
                } else {
                  checkError(assessment.section);

                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addAssessment(bool isLightMode) {
    int quantity = 1;
    double finalObtainedMarks = 0;
    double finalMaxMarks = 0;
    String section = 'Lecture';
    showDialog(
      context: context,
      builder: (context) {
        String? newAssessmentName;
        double? newAssessmentWeightage;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor:
                  isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
              title: Text(
                'Add Assessment',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isLightMode ? Colors.black : Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      dropdownColor: isLightMode
                          ? AppTheme.nearlyWhite
                          : AppTheme.nearlyBlack,
                      style: TextStyle(
                          color: isLightMode ? Colors.black : Colors.white),
                      value: section,
                      onChanged: (value) {
                        setState(() {
                          section = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'Lecture',
                          child: Text('Lecture'),
                        ),
                        DropdownMenuItem(
                          value: 'Lab',
                          child: Text('Lab'),
                        )
                      ],
                      decoration: InputDecoration(
                          labelText: 'Section',
                          labelStyle: TextStyle(
                              color:
                                  isLightMode ? Colors.black : Colors.white)),
                    ),
                    TextField(
                      style: TextStyle(
                          color: isLightMode ? Colors.black : Colors.white),
                      onChanged: (value) {
                        newAssessmentName = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Assessment Name',
                        labelStyle: TextStyle(
                            color: isLightMode ? Colors.black : Colors.white),
                      ),
                    ),
                    TextFormField(
                      style: TextStyle(
                          color: isLightMode ? Colors.black : Colors.white),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          newAssessmentWeightage = double.tryParse(value);
                        } else {
                          newAssessmentWeightage = null;
                        }
                      },
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Weightage',
                        labelStyle: TextStyle(
                            color: isLightMode ? Colors.black : Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quantity',
                            style: TextStyle(
                                color:
                                    isLightMode ? Colors.black : Colors.white),
                          ),
                          SizedBox(
                            width: 170,
                            child: Slider(
                              min: 1,
                              max: 10,
                              divisions: 10,
                              label: '$quantity',
                              value: quantity.toDouble(),
                              onChanged: (value) {
                                setState(() {
                                  quantity = value.toInt();
                                  _obtainedMarksControllers = List.generate(
                                    quantity,
                                    (_) => TextEditingController(),
                                  );
                                  _totalMarksControllers = List.generate(
                                    quantity,
                                    (_) => TextEditingController(),
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (int i = 0; i < quantity; i++)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (quantity != 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Text(
                                '#${i + 1}:',
                                style: TextStyle(
                                    color: isLightMode
                                        ? Colors.black
                                        : Colors.white),
                              ),
                            ),
                          TextFormField(
                            style: TextStyle(
                                color:
                                    isLightMode ? Colors.black : Colors.white),
                            controller: _totalMarksControllers[i],
                            onChanged: (value) {},
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Total Marks',
                              labelStyle: TextStyle(
                                  color: isLightMode
                                      ? Colors.black
                                      : Colors.white),
                            ),
                          ),
                          TextFormField(
                            style: TextStyle(
                                color:
                                    isLightMode ? Colors.black : Colors.white),
                            controller: _obtainedMarksControllers[i],
                            onChanged: (value) {},
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Obtained Marks',
                              labelStyle: TextStyle(
                                  color: isLightMode
                                      ? Colors.black
                                      : Colors.white),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel',
                      style: TextStyle(
                          fontSize: 12,
                          color: isLightMode ? Colors.black : Colors.white)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Add',
                      style: TextStyle(
                          fontSize: 12,
                          color: isLightMode ? Colors.black : Colors.white)),
                  onPressed: () {
                    if (newAssessmentName != null &&
                        newAssessmentWeightage != null &&
                        !_isAnyObtainedMarksExceedsTotal(quantity)) {
                      setState(() {
                        for (int i = 0; i < quantity; i++) {
                          finalObtainedMarks += double.tryParse(
                                  _obtainedMarksControllers[i].text) ??
                              0;
                          finalMaxMarks +=
                              double.tryParse(_totalMarksControllers[i].text) ??
                                  0;
                          _obtainedMarksControllers[i].clear();
                          _totalMarksControllers[i].clear();
                        }
                        if (finalMaxMarks != 0) {
                          if (section == 'Lecture') {
                            lectureAssessments.add(Assessment(
                              newAssessmentName!,
                              newAssessmentWeightage!,
                              finalObtainedMarks,
                              finalMaxMarks,
                              section: section,
                            ));
                          } else {
                            labAssessments.add(Assessment(
                              newAssessmentName!,
                              newAssessmentWeightage!,
                              finalObtainedMarks,
                              finalMaxMarks,
                              section: section,
                            ));
                          }
                        }
                        checkError(section);
                        _saveAssessments();
                        Navigator.pop(context);
                      });
                    } else {
                      if (!_isSnackBarVisible) {
                        setState(() {
                          _isSnackBarVisible = true;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                              SnackBar(
                                content: Text((newAssessmentName == null ||
                                        newAssessmentWeightage == null)
                                    ? 'Incomplete Data'
                                    : 'Obtained marks cannot be more than total marks.'),
                                backgroundColor: Colors.red,
                              ),
                            )
                            .closed
                            .then((_) {
                          setState(() {
                            _isSnackBarVisible = false;
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
      },
    );
  }

  bool _isAnyObtainedMarksExceedsTotal(int quantity) {
    for (int i = 0; i < quantity; i++) {
      double obtainedMarks =
          double.tryParse(_obtainedMarksControllers[i].text) ?? 0;
      double totalMarks = double.tryParse(_totalMarksControllers[i].text) ?? 0;
      if (obtainedMarks > totalMarks) {
        return true;
      }
    }
    return false;
  }

  void _deleteAssessment(Assessment assessment) {
    setState(() {
      if (assessment.section == 'Lecture') {
        lectureAssessments.remove(assessment);
      } else {
        labAssessments.remove(assessment);
      }
      checkError(assessment.section);
      _saveAssessments();
      deletedAssessment = assessment;
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
      if (deletedAssessment.section == 'Lecture') {
        lectureAssessments.add(deletedAssessment);
      } else {
        labAssessments.add(deletedAssessment);
      }
      checkError(deletedAssessment.section);
      _saveAssessments();
      _showUndoButton = false;
    });
  }

  void checkError(String section) {
    double totalAbs = 0;
    if (section == 'Lecture') {
      for (Assessment lectureAssessment in lectureAssessments) {
        totalAbs += lectureAssessment.weightage;
      }
    } else {
      for (Assessment labAssessment in labAssessments) {
        totalAbs += labAssessment.weightage;
      }
    }
    if (totalAbs > 100) {
      setState(() => error = true);
    } else {
      setState(() => error = false);
    }
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
          title: Text(
            'Absolutes Calculator',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black : Colors.white),
          ),
          actions: [
            _showUndoButton
                ? IconButton(
                    onPressed: _undoDelete,
                    icon: const Icon(
                      Icons.undo_rounded,
                      color: Colors.grey,
                    ))
                : Container(),
            error
                ? Padding(
                    padding: const EdgeInsets.only(right: 15.0),
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
                          color: isLightMode
                              ? AppTheme.nearlyBlack
                              : AppTheme.white,
                        ),
                        contentPadding: const EdgeInsets.all(6),
                        contentBorderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        infoTextAlign: TextAlign.center,
                      ),
                      dismissTriggerBehavior:
                          PopupDismissTriggerBehavior.anyWhere,
                      contentTitle:
                          'Warning! Total Weightage exceed 100. Data will not be saved. Edit / Delete extra Assessments.',
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.red,
                      ),
                    ),
                  )
                : Container(),
          ]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPartitions(
                'Lecture', lectureAssessments, lectureWeightage, isLightMode),
            _buildPartitions('Lab', labAssessments, labWeightage, isLightMode),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ActionButton(
              func: () => _addAssessment(isLightMode),
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

  Widget _buildPartitions(
      String sectionName,
      List<Assessment> sectionAssessments,
      double sectionWeightage,
      bool isLightMode) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isPresent = sectionAssessments.isNotEmpty;

    return (!isPresent)
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Text(
                  'No $sectionName Assessment found. Add an assessment using the " + " button.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: isLightMode
                    ? AppTheme.white
                    : themeProvider.primaryColor.withOpacity(0.2),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: AppTheme.grey.withOpacity(0.2),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0),
                ],
                border: Border.all(
                    color: isLightMode
                        ? AppTheme.grey
                        : themeProvider.primaryColor.withOpacity(0.8),
                    width: 3),
              ),
              child: ExpansionTile(
                title: Text(
                  sectionName,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          isLightMode ? AppTheme.nearlyBlack : AppTheme.white),
                ),
                subtitle: GestureDetector(
                  onTap: () => _editWeightage(
                      sectionWeightage, sectionName, isLightMode),
                  onLongPress: () => _editWeightage(
                      sectionWeightage, sectionName, isLightMode),
                  child: RichText(
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.start,
                    textDirection: TextDirection.ltr,
                    softWrap: true,
                    maxLines: 1,
                    textScaleFactor: 1,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: "Obtained Absolutes: ",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isLightMode
                                  ? AppTheme.nearlyBlack
                                  : AppTheme.white),
                        ),
                        TextSpan(
                          text: sectionName == 'Lecture'
                              ? "${(lectureWeightage * (lectureAbsolutes / 100)).toStringAsFixed(1)} "
                              : "${(labWeightage * (labAbsolutes / 100)).toStringAsFixed(1)} ",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isLightMode ? Colors.black : Colors.white),
                        ),
                        TextSpan(
                          text: ' / ${sectionWeightage.toStringAsFixed(1)}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isLightMode
                                  ? AppTheme.nearlyBlack
                                  : AppTheme.white),
                        ),
                      ],
                    ),
                  ),
                ),
                iconColor: Colors.grey,
                collapsedIconColor: Colors.grey,
                children: [
                  SizedBox(
                    height: 100.0 * sectionAssessments.length,
                    child: ListView.builder(
                      itemCount: sectionAssessments.length,
                      itemBuilder: (context, index) {
                        final assessment = sectionAssessments[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
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
                            onSwiped: (direction) =>
                                _deleteAssessment(assessment),
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
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    themeProvider.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: isLightMode
                                        ? AppTheme.grey
                                        : themeProvider.primaryColor
                                            .withOpacity(0.8),
                                    width: 3),
                              ),
                              child: ListTile(
                                title: Text(
                                  assessment.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: isLightMode
                                          ? Colors.black
                                          : Colors.white),
                                ),
                                subtitle: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "Marks ",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isLightMode
                                                ? AppTheme.nearlyBlack
                                                : AppTheme.white),
                                      ),
                                      TextSpan(
                                        text:
                                            "${assessment.obtainedMarks.toStringAsFixed(0)}/${assessment.totalMarks.toStringAsFixed(0)}",
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isLightMode
                                                ? Colors.black
                                                : Colors.white),
                                      ),
                                      TextSpan(
                                          text: "\nWeightage ",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: isLightMode
                                                  ? AppTheme.nearlyBlack
                                                  : AppTheme.white)),
                                      TextSpan(
                                        text:
                                            "${assessment.weightage.toStringAsFixed(1)}%",
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isLightMode
                                                ? Colors.black
                                                : Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: isLightMode
                                        ? AppTheme.nearlyBlack
                                        : AppTheme.white,
                                  ), // Changed the delete icon to edit icon
                                  onPressed: () {
                                    _editAssessment(
                                        assessment, index, isLightMode);
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
