import 'dart:io';

import 'package:GreyDo/pages/home_page.dart';
import 'package:GreyDo/pages/test_page.dart';
import 'package:GreyDo/utils/local_notification_service.dart';
import 'package:GreyDo/utils/util_colors.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


Future<void> requestPermissions(List<Permission> permissions) async {
  for (var permission in permissions) {
    // Request permission and get status
    var status = await permission.request();

    if (status.isGranted) {
      print('${permission.toString().split('.')[1]} permission granted');
    } else if (status.isDenied) {
      print('${permission.toString().split('.')[1]} permission denied');
    } else if (status.isPermanentlyDenied) {
      print('${permission.toString().split('.')[1]} permission permanently denied. Please enable it in settings.');
      await openAppSettings(); // Opens app settings if permanently denied
    }
  }
}

Future<int> getAndroidVersion() async {
  if (Platform.isAndroid) {
    return int.parse((await Process.run('getprop', ['ro.build.version.sdk'])).stdout.trim());
  }
  return 0; // Return 0 for non-Android platforms
}

Future<void> initializePermissions() async {
  // Determine platform-specific permissions
  List<Permission> permissions = [];

  // Add notification permission for Android 13+ (SDK 33 and above)
  if (Platform.isAndroid && (await getAndroidVersion()) >= 33) {
    permissions.add(Permission.notification);
    permissions.add(Permission.scheduleExactAlarm);
  }

  // Request permissions
  await requestPermissions(permissions);
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final LocalNotificationService notificationService = LocalNotificationService();
  await notificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    initializePermissions();
  }

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
