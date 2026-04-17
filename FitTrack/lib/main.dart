import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import 'provider/auth_provider.dart';
import 'provider/home_provider.dart';
import 'provider/nutrition_provider.dart';
import 'provider/workout_provider.dart';
import 'screens/splash_screen.dart';
import 'thems/colors.dart';

/// ✅ SERVICES
import 'services/supabase_service.dart';
import 'services/notification_service.dart';

/// 🔥 Exact Alarm Permission
Future<void> requestExactAlarmPermission() async {
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  

  /// 🔔 2. LOCAL NOTIFICATION INIT (SERVICE)
  await NotificationService.init();

  /// 🔥 3. EXACT ALARM PERMISSION
  await requestExactAlarmPermission();

  /// 🔥 4. ALARM MANAGER INIT
  await AndroidAlarmManager.initialize();

  /// 🔥 5. SUPABASE INIT (SERVICE)
  await SupabaseService.init();

  /// 🚀 RUN APP
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// 🎯 MAIN APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FitTrack",
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black),
      builder: (context, child) {
        return AppBackground(child: child!);
      },
      home: const SplashScreen(),
    );
  }
}
