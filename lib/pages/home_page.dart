import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/local_notification_service.dart';
import '../utils/todo_list.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../utils/util_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<List<dynamic>> toDoList = []; // Each task is [description, isCompleted, dateTime]
  final TextEditingController _controller = TextEditingController();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  /// Initialize notification plugin
  Future<void> _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          'launcher_icon',
        ); // Replace 'app_icon' with your icon name
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedList = toDoList.map((task) {
      return jsonEncode([
        task[0], // Task description
        task[1], // Task completion status
        task[2]?.toIso8601String(), // Convert DateTime to String
      ]);
    }).toList();
    await prefs.setStringList("tasks", encodedList);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedTasks = prefs.getStringList("tasks");

    if (savedTasks != null) {
      setState(() {
        toDoList = savedTasks.map((task) {
          var decodedTask = jsonDecode(task);
          return [
            decodedTask[0], // Task description
            decodedTask[1], // Task completion status
            decodedTask[2] != null ? DateTime.parse(decodedTask[2]) : null, // Convert String back to DateTime
          ];
        }).toList();
      });

      // Reschedule notifications for loaded tasks
      for (int i = 0; i < toDoList.length; i++) {
        if (!toDoList[i][1] && toDoList[i][2] is DateTime) {
          _scheduleNotification(i, toDoList[i][0], toDoList[i][2]);
        }
      }
    }
  }


  /// Schedule a notification for a task
  Future<void> _scheduleNotification(
    int index,
    String title,
    DateTime scheduledDate,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'your_channel_id',
          'Your Channel Name',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      index, // Unique ID for the notification
      "Task Reminder",
      title,
      tz.TZDateTime.from(scheduledDate, tz.local), // Scheduled date and time
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancel a notification for a task
  Future<void> _cancelNotification(int index) async {
    await flutterLocalNotificationsPlugin.cancel(index);
  }

  @override
  void initState() {
    super.initState();
    _initializeNotifications(); // Initialize notifications
    _loadTasks();
  }

  @override
  void dispose() {
    _saveTasks();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int completedTaskCount = toDoList.where((task) => task[1] == true).length;

    return Scaffold(
      appBar: AppBar(title: const Text("GreyDo")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Add a new todo item",
                filled: true,
                fillColor: Colors.deepPurple.shade200,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: UtilColors.deePurpleColor),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: UtilColors.deePurpleColor),
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Completed $completedTaskCount of ${toDoList.length}",
                style: const TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          ),
          if (toDoList.isEmpty)
            const Center(
              child: Text(
                "No task",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: toDoList.length,
                itemBuilder: (context, index) {
                  return TodoList(
                    toDoList: toDoList,
                    index: index,
                    taskCompleted: toDoList[index][1],
                    onChecked: (value) async {
                      setState(() {
                        toDoList[index][1] = value ?? false;
                      });
                      if (value == true) {
                        await _cancelNotification(
                          index,
                        ); // Cancel notification when task is completed
                      }
                      _saveTasks();
                    },
                    onDelete: () async {
                      setState(() {
                        toDoList.removeAt(index);
                      });
                      await _cancelNotification(
                        index,
                      ); // Cancel notification when task is deleted
                      _saveTasks();
                    },
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_controller.text.isEmpty) {
            final materialBanner = MaterialBanner(
              /// need to set following properties for best effect of awesome_snackbar_content
              elevation: 0,
              backgroundColor: Colors.transparent,
              forceActionsBelow: true,
              content: AwesomeSnackbarContent(
                title: 'Missing content!!',
                message: 'Type some task text into the textfield!',

                /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                contentType: ContentType.failure,
                // to configure for material banner
                inMaterialBanner: true,
              ),
              actions: const [SizedBox.shrink()],
            );

            ScaffoldMessenger.of(context)
              ..hideCurrentMaterialBanner()
              ..showMaterialBanner(materialBanner);

            return;
          }
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );

          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (pickedDate != null && pickedTime != null) {
            DateTime dateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );

            setState(() {
              toDoList.insert(0, [
                _controller.text[0].toUpperCase() +
                    _controller.text.substring(1).toLowerCase(),
                false,
                dateTime,
              ]);
              _controller.clear();
            });

            // Schedule notification for the new task
            _scheduleNotification(0, toDoList[0][0], dateTime);

            _saveTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
