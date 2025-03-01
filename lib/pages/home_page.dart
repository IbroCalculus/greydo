import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greydo/utils/util_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/todo_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<List<dynamic>> toDoList =
      []; // Each task is [description, isCompleted, dateTime]
  final TextEditingController _controller = TextEditingController();

  /// Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedList =
        toDoList.map((task) => jsonEncode(task)).toList();
    await prefs.setStringList("tasks", encodedList);
  }

  /// Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedTasks = prefs.getStringList("tasks");
    if (savedTasks != null) {
      setState(() {
        toDoList =
            savedTasks
                .map((task) => jsonDecode(task) as List<dynamic>)
                .toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
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
                "$completedTaskCount of ${toDoList.length}",
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
                    onChecked: (value) {
                      setState(() {
                        toDoList[index][1] = value ?? false;
                      });
                      _saveTasks();
                    },
                    onDelete: () {
                      setState(() {
                        toDoList.removeAt(index);
                      });
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
            _saveTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
