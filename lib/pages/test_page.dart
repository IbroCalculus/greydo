import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test page"),),
      body: Center(
        child: Checkbox(
          value: isChecked,
          onChanged: (value) {
          setState(() {
            isChecked = !isChecked;
          });
          print("isChecked: ${isChecked}");
        },),
      ),
    );
  }
}
