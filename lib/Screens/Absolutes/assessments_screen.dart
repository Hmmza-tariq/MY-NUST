import 'package:flutter/material.dart';
import '../../Components/action_button.dart';
import '../../Core/assessment_provider.dart';
import '../../Core/assessments.dart';
import '../../Core/app_theme.dart';
import '../../Core/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AssessmentsScreen extends StatefulWidget {
  static const String id = "_Assessment_Screen";
  final String section;

  const AssessmentsScreen({Key? key, required this.section}) : super(key: key);

  @override
  AssessmentsScreenState createState() => AssessmentsScreenState();
}

class AssessmentsScreenState extends State<AssessmentsScreen> {
  List<Assessment> assessments = [];
  bool _showUndoButton = false;
  late Assessment deletedAssessment;
  double buttonsPadding = 20;
  bool error = false;
  bool _isSnackBarVisible = false;
  List<TextEditingController> _obtainedMarksControllers = [];
  List<TextEditingController> _totalMarksControllers = [];

  @override
  void initState() {
    super.initState();
    _loadAssessments();
    _obtainedMarksControllers.add(TextEditingController());
    _totalMarksControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _saveAssessments();
    super.dispose();
  }

  void _editAssessment(Assessment assessment) {
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
        String? editedAssessmentSection = assessment.section;

        return AlertDialog(
          title: const Text('Edit Assessment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: editedAssessmentSection,
                  onChanged: (value) {
                    setState(() {
                      editedAssessmentSection = value;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'Lecture', child: Text('Lecture')),
                    DropdownMenuItem(value: 'Lab', child: Text('Lab')),
                  ],
                  decoration: const InputDecoration(labelText: 'Section'),
                ),
                TextField(
                  controller: nameController,
                  onChanged: (value) {},
                  decoration: const InputDecoration(
                    labelText: 'Assessment Name',
                  ),
                ),
                TextFormField(
                  controller: weightageController,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      editedAssessmentWeightage = double.tryParse(value);
                    } else {
                      editedAssessmentWeightage = null;
                    }
                  },
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Weightage',
                  ),
                ),
                TextFormField(
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
                  decoration: const InputDecoration(
                    labelText: 'Obtained Marks',
                  ),
                ),
                TextFormField(
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
                  decoration: const InputDecoration(
                    labelText: 'Total Marks',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (editedAssessmentSection != null &&
                    editedAssessmentWeightage != null &&
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
                      assessments.remove(assessment);
                      assessments.add(Assessment(
                        editedAssessmentName,
                        editedAssessmentWeightage!,
                        editedAssessmentObtainedMarks!,
                        editedAssessmentTotalMarks!,
                        section: editedAssessmentSection!,
                      ));
                      _saveAssessments();
                      Navigator.pop(context);
                    });
                  }
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addAssessment() {
    int quantity = 1;
    double finalObtainedMarks = 0;
    double finalMaxMarks = 0;
    showDialog(
      context: context,
      builder: (context) {
        String? newAssessmentName;
        double? newAssessmentWeightage;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Assessment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        newAssessmentName = value;
                      },
                      decoration:
                          const InputDecoration(labelText: 'Assessment Name'),
                    ),
                    TextFormField(
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          newAssessmentWeightage = double.tryParse(value);
                        } else {
                          newAssessmentWeightage = null;
                        }
                      },
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Weightage'),
                    ),
                    DropdownButtonFormField<int>(
                      value: quantity,
                      onChanged: (value) {
                        setState(() {
                          quantity = value!;
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
                      items: List.generate(
                        10,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        ),
                      ),
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                    for (int i = 0; i < quantity; i++)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (quantity != 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Text('#${i + 1}:'),
                            ),
                          TextFormField(
                            controller: _obtainedMarksControllers[i],
                            onChanged: (value) {},
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                                labelText: 'Obtained Marks'),
                          ),
                          TextFormField(
                            controller: _totalMarksControllers[i],
                            onChanged: (value) {},
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration:
                                const InputDecoration(labelText: 'Total Marks'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Add'),
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
                          assessments.add(Assessment(
                            newAssessmentName!,
                            newAssessmentWeightage!,
                            finalObtainedMarks,
                            finalMaxMarks,
                            section: widget.section,
                          ));
                        }
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
      assessments.remove(assessment);
      _saveAssessments();
      deletedAssessment = assessment;
      _showUndoButton = true;
      buttonsPadding = 50;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showUndoButton = false;
          buttonsPadding = 20;
        });
      }
    });
  }

  void _undoDelete() {
    setState(() {
      assessments.add(deletedAssessment);
      _saveAssessments();
      _showUndoButton = false;
      buttonsPadding = 20;
    });
  }

  void _saveAssessments() async {
    checkError();
    if (!error) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> assessmentList = assessments
          .map((assessment) => {
                'name': assessment.name,
                'weightage': assessment.weightage,
                'obtainedMarks': assessment.obtainedMarks,
                'totalMarks': assessment.totalMarks,
                'section': assessment.section,
              })
          .toList();
      prefs.setString('assessments', json.encode(assessmentList));
      // ignore: use_build_context_synchronously
      Provider.of<AssessmentProvider>(context, listen: false)
          .setAssessments(assessments);
    }
  }

  void _loadAssessments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? assessmentJson = prefs.getString('assessments');
    if (assessmentJson != null) {
      List<dynamic> assessmentList = json.decode(assessmentJson);
      setState(() {
        assessments = assessmentList
            .map((assessmentData) => Assessment(
                  assessmentData['name'],
                  assessmentData['weightage'],
                  assessmentData['obtainedMarks'],
                  assessmentData['totalMarks'],
                  section: assessmentData['section'],
                ))
            .toList();
        if (assessments.isEmpty) {
          assessments = [
            Assessment('Quiz', 15, 10, 10, section: 'Lecture'),
            Assessment('Assignment', 15, 10, 10, section: 'Lecture'),
            Assessment('Mid', 30, 100, 100, section: 'Lecture'),
            Assessment('Final', 40, 100, 100, section: 'Lecture'),
            Assessment('Lab tasks', 30, 100, 100, section: 'Lab'),
            Assessment('Lab mid', 30, 100, 100, section: 'Lab'),
            Assessment('Lab final', 40, 100, 100, section: 'Lab'),
          ];
        }
      });
    }
  }

  void checkError() {
    double totalAbs = 0;
    for (Assessment a in assessments) {
      if (a.section == widget.section) {
        totalAbs += a.weightage;
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
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
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
          widget.section,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isLightMode ? Colors.black : Colors.white),
        ),
      ),
      body: Column(
        children: [
          if (error)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Warning! Total Weightage exceed 100. Data will not be saved, edit / delete extra Assessments.',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          if (widget.section == "Lecture") _buildSection('Lecture'),
          if (widget.section == "Lab") _buildSection('Lab'),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(left: 30, bottom: buttonsPadding),
        child: ActionButton(
          func: _addAssessment,
          icon: Icons.add,
          color: themeProvider.primaryColor,
        ),
      ),
      bottomSheet: _showUndoButton
          ? GestureDetector(
              onTap: () {
                _undoDelete();
              },
              child: Container(
                height: 50,
                color: Colors.red,
                child: const Center(
                  child: Text(
                    'Undo',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSection(String sectionName) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    List<Assessment> sectionAssessments = assessments
        .where((assessment) => assessment.section == sectionName)
        .toList();
    bool isPresent = sectionAssessments.isNotEmpty;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Expanded(
          child: (!isPresent)
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Center(
                    child: Text(
                      'No $sectionName Assessment found. Add an assessment using the "Add Assessment" button.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: sectionAssessments.length,
                  itemBuilder: (context, index) {
                    final assessment = sectionAssessments[index];
                    return GestureDetector(
                      onTap: () {
                        _editAssessment(assessment);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: themeProvider.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    themeProvider.primaryColor.withOpacity(0.8),
                                width: 3),
                          ),
                          child: ListTile(
                            title: Text(
                              assessment.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Marks "),
                                Text(
                                  "${assessment.obtainedMarks.toStringAsFixed(0)}/${assessment.totalMarks.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Text(", Weightage "),
                                Text(
                                  "${assessment.weightage.toStringAsFixed(1)}%",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons
                                  .delete), // Changed the delete icon to edit icon
                              onPressed: () {
                                _deleteAssessment(assessment);
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
