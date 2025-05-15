import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:vpn_basic_project/utils/colors.dart';
import 'helpers/ad_helper.dart';
import 'helpers/config.dart';
import 'helpers/pref.dart';
import 'screens/splash_screen.dart';

// Global object for accessing device screen size
late Size mq;

late FirebaseAnalytics analytics;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enter full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  // Firebase initialization
  await Firebase.initializeApp();

  // Initialize Firebase Analytics
  analytics = FirebaseAnalytics.instance;

  // Enable Crashlytics (for Flutter errors)
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Initializing remote config
  await Config.initConfig();

  // Initialize Hive storage
  await Pref.initializeHive();

  // Initialize ads
  await AdHelper.initAds();

  // Set orientation to portrait only
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  ).then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'OpenVpn Demo',
      home: SplashScreen(),

      // Theme
      theme: ThemeData(
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 3),
        useMaterial3: false,
      ),
      themeMode: Pref.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 3),
      ),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}

extension AppTheme on ThemeData {
  Color get lightText => Pref.isDarkMode ? Colors.white70 : Colors.black54;
  Color get bottomNav => Pref.isDarkMode ? Colors.white12 : kDefaultBlueColor;
}
