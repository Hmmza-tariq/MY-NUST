import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import '../../Components/action_button.dart';
import '../../Core/app_theme.dart';
import '../../Core/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleTaskScreen extends StatefulWidget {
  static String id = "ScheduleTask_Screen";

  const ScheduleTaskScreen({super.key});

  @override
  TodoListPageState createState() => TodoListPageState();
}

class TodoListPageState extends State<ScheduleTaskScreen> {
  final List<String> _tasks = [];
  bool _showUndoButton = false;
  String _lastRemovedTask = '';
  final String _tasksKey = 'tasks_key';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks.clear();
      _tasks.addAll(prefs.getStringList(_tasksKey) ?? []);
    });
  }

  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_tasksKey, _tasks);
  }

  void _addTask(String task) {
    setState(() {
      _tasks.add(task);
      _saveTasks();
    });
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index] = _tasks[index].startsWith("✓ ")
          ? _tasks[index].substring(2)
          : "✓ ${_tasks[index]}";
      _saveTasks();
    });
  }

  void _deleteTask(int index) {
    _lastRemovedTask = _tasks[index];
    _tasks.removeAt(index);
    _showUndoButton = true;
    _saveTasks();
    setState(() {});
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showUndoButton = false;
        });
      }
    });
  }

  void _showEditTaskDialog(int index, bool isLightMode) {
    String task = '';
    bool isSnackBarVisible = false;

    showDialog(
      context: context,
      builder: (context) {
        TextEditingController editedTaskController =
            TextEditingController(text: _tasks[index]);
        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            'Edit Task',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isLightMode ? Colors.black : Colors.white,
            ),
          ),
          content: TextField(
            style: TextStyle(color: isLightMode ? Colors.black : Colors.white),
            controller: editedTaskController,
            onChanged: (value) {
              setState(() {
                task = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Task',
              labelStyle:
                  TextStyle(color: isLightMode ? Colors.black : Colors.white),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                'Save',
                style:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
              ),
              onPressed: () {
                if (task != '') {
                  _tasks[index] = task;
                  _saveTasks();
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
                        message: "Incorrect Task",
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

  void addTask(bool isLightMode) {
    bool isSnackBarVisible = false;
    showDialog(
      context: context,
      builder: (context) {
        String newTask = '';
        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            'Add Task',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isLightMode ? Colors.black : Colors.white,
            ),
          ),
          content: TextField(
            decoration: InputDecoration(
              labelText: 'Task',
              labelStyle:
                  TextStyle(color: isLightMode ? Colors.black : Colors.white),
            ),
            onChanged: (value) {
              newTask = value;
            },
            style: TextStyle(color: isLightMode ? Colors.black : Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Add',
                style:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
              ),
              onPressed: () {
                if (newTask.isNotEmpty) {
                  _addTask(newTask);
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
                        message: "Incorrect Task",
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

  void _undoDelete() {
    setState(() {
      _showUndoButton = false;
    });
    if (_lastRemovedTask.isNotEmpty) {
      _tasks.add(_lastRemovedTask);
      _lastRemovedTask = '';
      _saveTasks();
      setState(() {});
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
          'To Do list',
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
      body: _tasks.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(35.0),
              child: Center(
                child: Text('No Task found. Add a Task using the " + " button.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.grey,
                    )),
              ),
            )
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final isTaskCompleted = _tasks[index].startsWith("✓ ");
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
                    onSwiped: (direction) => _deleteTask(index),
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
                        color: themeProvider.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isLightMode
                                ? AppTheme.grey
                                : themeProvider.primaryColor.withOpacity(0.8),
                            width: 3),
                      ),
                      child: ListTile(
                        title: Text(
                          _tasks[index],
                          style: TextStyle(
                              decoration: isTaskCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: !isLightMode
                                  ? isTaskCompleted
                                      ? Colors.grey
                                      : Colors.white
                                  : isTaskCompleted
                                      ? AppTheme.grey
                                      : Colors.black),
                        ),
                        trailing: !isTaskCompleted
                            ? IconButton(
                                icon: const Icon(Icons.edit),
                                color:
                                    isLightMode ? AppTheme.grey : Colors.white,
                                onPressed: () {
                                  _showEditTaskDialog(index, isLightMode);
                                },
                              )
                            : null,
                        leading: Theme(
                          data: ThemeData(
                              unselectedWidgetColor:
                                  isLightMode ? AppTheme.grey : Colors.white),
                          child: Checkbox(
                            activeColor:
                                isLightMode ? AppTheme.grey : Colors.white,
                            checkColor: isLightMode
                                ? Colors.white
                                : AppTheme.nearlyBlack,
                            value: isTaskCompleted,
                            onChanged: (value) => _toggleTask(index),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ActionButton(
            func: () {
              addTask(isLightMode);
            },
            icon: Icons.add,
            color: themeProvider.primaryColor),
      ),
    );
  }
}
