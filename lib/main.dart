import 'package:GreyDo/pages/home_page.dart';
import 'package:GreyDo/utils/util_colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: UtilColors.deePurpleColor,
          foregroundColor: UtilColors.whiteColor,
        ),
        scaffoldBackgroundColor: UtilColors.scaffoldBgColor,
      ),
      home: HomePage(),
      // home: TestPage(),
    );
  }
}
