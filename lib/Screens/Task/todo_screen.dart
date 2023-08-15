import 'package:flutter/material.dart';
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
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showUndoButton = false;
        });
      }
    });
  }

  void _showEditTaskDialog(int index, bool isLightMode) {
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
                _tasks[index] = value;
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
                _saveTasks();
                Navigator.pop(context);
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
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
                      leading: Theme(
                        data: ThemeData(
                            unselectedWidgetColor:
                                isLightMode ? AppTheme.grey : Colors.white),
                        child: Checkbox(
                          activeColor:
                              isLightMode ? AppTheme.grey : Colors.white,
                          checkColor:
                              isLightMode ? Colors.white : AppTheme.nearlyBlack,
                          value: isTaskCompleted,
                          onChanged: (value) => _toggleTask(index),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        color: isLightMode ? AppTheme.grey : Colors.white,
                        onPressed: () => _deleteTask(index),
                      ),
                      onTap: () {
                        !isTaskCompleted
                            ? _showEditTaskDialog(index, isLightMode)
                            : null;
                      },
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

  void addTask(bool isLightMode) {
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
                }
              },
            ),
          ],
        );
      },
    );
  }
}
