import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:swipeable_tile/swipeable_tile.dart';
import '../../Components/action_button.dart';
import '../../Components/toasts.dart';
import '../../Core/app_Theme.dart';
import '../../Core/notification_service.dart';
import '../../Provider/theme_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../Core/events.dart';

class CalendarScreen extends StatefulWidget {
  static String id = "Calendar_Screen";

  const CalendarScreen({super.key});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now().toLocal().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 000,
      isUtc: true);
  final TextEditingController _taskController = TextEditingController();
  Map<DateTime, List<Event>> _events = {};
  bool _showUndoButton = false;
  Event _deletedEvent = Event();
  final ValueNotifier<DateTime?> _focusedDayNotifier =
      ValueNotifier<DateTime?>(null);

  @override
  void initState() {
    _loadEvents();
    super.initState();
    setState(() {
      _focusedDayNotifier.value = _selectedDay;
    });
  }

  @override
  void dispose() {
    _focusedDayNotifier.dispose();
    super.dispose();
  }

  void _saveEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> eventList = _events.entries.map((entry) {
      Map<String, dynamic> eventData = {
        'date': entry.key.toIso8601String(),
        'events': entry.value.map((event) => event.title).toList(),
      };
      return json.encode(eventData);
    }).toList();
    prefs.setStringList('events', eventList);
    setState(() {});
  }

  void _loadEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? eventList = prefs.getStringList('events');
    if (eventList != null) {
      Map<DateTime, List<Event>> loadedEvents = Map.fromIterable(
        eventList,
        key: (eventData) {
          Map<String, dynamic> parsedData = json.decode(eventData);
          DateTime date = DateTime.parse(parsedData['date']);
          return date;
        },
        value: (eventData) {
          Map<String, dynamic> parsedData = json.decode(eventData);
          List<dynamic> eventTitles = parsedData['events'] as List<dynamic>;
          List<Event> events =
              eventTitles.map((title) => Event(title: title)).toList();
          return events;
        },
      );
      setState(() {
        _events = loadedEvents;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      focusedDay = _selectedDay = selectedDay.copyWith(
          hour: 0,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 000,
          isUtc: true);
    });
  }

  void _showAddEventDialog(bool isLightMode) {
    bool notificationAllowed = false;
    DateTime selectedTime = DateTime.now();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            'Add Event',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isLightMode ? Colors.black : Colors.white,
            ),
          ),
          content: StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    style: TextStyle(
                        color: isLightMode ? Colors.black : Colors.white),
                    controller: _taskController,
                    decoration: InputDecoration(
                      labelText: 'Event',
                      labelStyle: TextStyle(
                          color: isLightMode ? Colors.black : Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SwitchListTile(
                      activeTrackColor: AppTheme.darkText,
                      title: Text(
                        'Remind through notification?',
                        style: TextStyle(
                            fontSize: 14,
                            color: isLightMode ? Colors.black : Colors.white),
                      ),
                      value: notificationAllowed,
                      onChanged: (bool value) {
                        setState(() {
                          NotificationService().requestNotificationPermission();
                          notificationAllowed = value;
                        });
                      },
                    ),
                  ),
                  (notificationAllowed)
                      ? ElevatedButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                                isLightMode ? AppTheme.darkText : Colors.white,
                          ),
                          onPressed: () {
                            picker.DatePicker.showTimePicker(context,
                                theme: picker.DatePickerTheme(
                                  backgroundColor: isLightMode
                                      ? Colors.white
                                      : AppTheme.nearlyBlack,
                                  itemStyle: TextStyle(
                                      fontSize: 14,
                                      color: isLightMode
                                          ? AppTheme.nearlyBlack
                                          : Colors.white),
                                  doneStyle: TextStyle(
                                      color: isLightMode
                                          ? Colors.black
                                          : Colors.white),
                                  cancelStyle: TextStyle(
                                      color: isLightMode
                                          ? Colors.black
                                          : Colors.white),
                                ),
                                showSecondsColumn: false,
                                showTitleActions: true, onConfirm: (date) {
                              setState(() {
                                selectedTime = DateTime.now().copyWith(
                                    year: _selectedDay.year,
                                    month: _selectedDay.month,
                                    day: _selectedDay.day,
                                    hour: date.hour,
                                    minute: date.minute,
                                    second: 0);
                              });
                            },
                                currentTime: DateTime.now(),
                                locale: picker.LocaleType.en);
                          },
                          child: Text(
                            'Add Time',
                            style: TextStyle(
                                fontSize: 14,
                                color: isLightMode
                                    ? Colors.white
                                    : AppTheme.nearlyBlack),
                          ),
                        )
                      : Container(),
                ],
              ),
            );
          }),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
              ),
              onPressed: () {
                _taskController.clear();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                'Add',
                style:
                    TextStyle(color: isLightMode ? Colors.black : Colors.white),
              ),
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  setState(() {
                    if (_events[_selectedDay] == null) {
                      _events[_selectedDay] = [];
                    }
                  });
                  if (notificationAllowed) {
                    int id = Random().nextInt(9999999);
                    _events[_selectedDay]!.add(Event(
                        title: _taskController.text,
                        id: id,
                        notification: true,
                        eventTime: selectedTime));
                    NotificationService().scheduleNotification(
                        id: id,
                        title: 'Reminder:',
                        body: _taskController.text,
                        scheduledNotificationDateTime: selectedTime);
                  } else {
                    _events[_selectedDay]!.add(Event(
                      title: _taskController.text,
                    ));
                  }
                  _saveEvents();
                  _taskController.clear();
                  Navigator.pop(context);
                } else {
                  Toast().errorToast(context, 'Incorrect Event');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditEventDialog(Event event, bool isLightMode) {
    String title = event.title;
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController editedEventController =
            TextEditingController(text: event.title);
        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            'Edit Event',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isLightMode ? Colors.black : Colors.white,
            ),
          ),
          content: TextField(
            style: TextStyle(color: isLightMode ? Colors.black : Colors.white),
            controller: editedEventController,
            onChanged: (value) {
              setState(() {
                title = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Event',
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
                if (title.isNotEmpty) {
                  event.title = title;
                  _saveEvents();
                  Navigator.pop(context);
                } else {
                  Toast().errorToast(context, 'Incorrect Event');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteEvent(Event event) {
    setState(() {
      _showUndoButton = true;
      _deletedEvent = event;
      _events[_selectedDay]!.remove(_deletedEvent);
      if (_deletedEvent.notification == true) {
        NotificationService().cancelNotification(_deletedEvent.id);
      }
    });
    _saveEvents();
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
      _showUndoButton = false;
      if (_events[_selectedDay] == null) {
        _events[_selectedDay] = [];
      }
      _events[_selectedDay]!.add(_deletedEvent);
    });
    if (_deletedEvent.notification == true) {
      NotificationService().scheduleNotification(
          id: _deletedEvent.id,
          title: 'Reminder:',
          body: _deletedEvent.title,
          scheduledNotificationDateTime:
              _deletedEvent.eventTime ?? _selectedDay);
    }
    _saveEvents();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    bool isLightMode = themeProvider.isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    int diff = DateTime.now().difference(_selectedDay).inDays.abs();
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
          'Calendar',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Container(
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isLightMode
                          ? AppTheme.grey
                          : themeProvider.primaryColor.withOpacity(0.8),
                      width: 3),
                ),
                child: TableCalendar<Event>(
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  firstDay: DateTime.utc(2019),
                  lastDay: DateTime.utc(2030),
                  focusedDay: _focusedDayNotifier.value ?? DateTime.now(),
                  calendarFormat: CalendarFormat.month,
                  onPageChanged: (focusedDay) {
                    _focusedDayNotifier.value = focusedDay;
                  },
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: _onDaySelected,
                  eventLoader: (day) => _events[day] ?? [],
                  headerStyle: HeaderStyle(
                      leftChevronIcon: Icon(Icons.chevron_left,
                          color: !isLightMode ? Colors.white : Colors.black),
                      rightChevronIcon: Icon(Icons.chevron_right,
                          color: !isLightMode ? Colors.white : Colors.black),
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                          fontFamily: AppTheme.fontName,
                          color: !isLightMode ? Colors.white : Colors.black)),
                  calendarStyle: CalendarStyle(
                    rangeHighlightColor: const Color(0xFFBBDDFF),
                    markerDecoration: const BoxDecoration(
                        color: Colors.deepOrange, shape: BoxShape.circle),
                    todayTextStyle: const TextStyle(
                        color: Color(0xFFFAFAFA), fontSize: 16.0),
                    todayDecoration: BoxDecoration(
                        color: AppTheme.grey.withOpacity(.3),
                        shape: BoxShape.circle),
                    selectedTextStyle: const TextStyle(
                        color: Color(0xFFFAFAFA), fontSize: 16.0),
                    selectedDecoration: const BoxDecoration(
                        color: AppTheme.grey, shape: BoxShape.circle),
                    rangeStartTextStyle: const TextStyle(
                        color: Color(0xFFFAFAFA), fontSize: 16.0),
                    rangeStartDecoration: const BoxDecoration(
                        color: Color(0xFF6699FF), shape: BoxShape.circle),
                    rangeEndTextStyle: const TextStyle(
                        color: Color(0xFFFAFAFA), fontSize: 16.0),
                    rangeEndDecoration: const BoxDecoration(
                        color: Color(0xFF6699FF), shape: BoxShape.circle),
                    withinRangeTextStyle: const TextStyle(),
                    withinRangeDecoration:
                        const BoxDecoration(shape: BoxShape.circle),
                    outsideTextStyle: const TextStyle(color: Color(0xFFAEAEAE)),
                    outsideDecoration:
                        const BoxDecoration(shape: BoxShape.circle),
                    disabledTextStyle:
                        const TextStyle(color: Color(0xFFBFBFBF)),
                    disabledDecoration:
                        const BoxDecoration(shape: BoxShape.circle),
                    holidayTextStyle: const TextStyle(color: Color(0xFF5C6BC0)),
                    holidayDecoration: const BoxDecoration(
                        border: Border.fromBorderSide(
                            BorderSide(color: Color(0xFF9FA8DA), width: 1.4)),
                        shape: BoxShape.circle),
                    weekendTextStyle: TextStyle(
                      color: !isLightMode == true
                          ? AppTheme.white.withOpacity(.2)
                          : AppTheme.nearlyBlack.withOpacity(.4),
                    ),
                    weekendDecoration:
                        const BoxDecoration(shape: BoxShape.circle),
                    weekNumberTextStyle:
                        const TextStyle(fontSize: 12, color: Color(0xFFBFBFBF)),
                    defaultTextStyle: TextStyle(
                      color: !isLightMode == true
                          ? AppTheme.white.withOpacity(.5)
                          : AppTheme.nearlyBlack.withOpacity(.6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (diff == 0)
                            ? ''
                            : _selectedDay.isAfter(DateTime.now())
                                ? 'Days After Today: '
                                : 'Days Before Today: ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            color: isLightMode ? Colors.black : Colors.white),
                      ),
                      Text(
                        (diff == 0)
                            ? ''
                            : '${DateTime.now().difference(_selectedDay).inDays.abs()}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLightMode ? Colors.black : Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Events:',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isLightMode ? Colors.black : Colors.white),
                  ),
                  const SizedBox(height: 10),
                  if ((_events[_selectedDay] != null))
                    if (_events[_selectedDay]!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _events[_selectedDay]!
                            .map(
                              (event) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
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
                                  onSwiped: (direction) => _deleteEvent(event),
                                  backgroundBuilder:
                                      (context, direction, progress) {
                                    return AnimatedBuilder(
                                      animation: progress,
                                      builder: (context, child) {
                                        return AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 400),
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
                                      color: themeProvider.primaryColor
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: isLightMode
                                              ? AppTheme.grey
                                              : themeProvider.primaryColor
                                                  .withOpacity(0.8),
                                          width: 3),
                                    ),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              event.title,
                                              style: TextStyle(
                                                  color: !isLightMode
                                                      ? Colors.white
                                                      : Colors.black),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            color: isLightMode
                                                ? AppTheme.grey
                                                : Colors.white,
                                            onPressed: () {
                                              _showEditEventDialog(
                                                  event, isLightMode);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      )
                    else
                      const Text(
                        'No Event Found. Add an Event using the " + " button.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      )
                  else
                    const Text(
                      'No Event Found. Add an Event using the " + " button.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ActionButton(
            func: () {
              _showAddEventDialog(isLightMode);
            },
            icon: Icons.add,
            color: themeProvider.primaryColor),
      ),
    );
  }
}
