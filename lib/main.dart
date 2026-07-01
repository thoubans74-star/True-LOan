import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tm/login/splash.dart';
import 'package:tm/theme_manager.dart';
import 'package:tm/api_services/profile_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeManager.init();
  await ProfileApiService.loadFromPrefs();

  // Retrieve and print current application version from pubspec.yaml
  final packageInfo = await PackageInfo.fromPlatform();
  final String appVer = packageInfo.buildNumber;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_version', appVer);

  // Retrieve and store device_id in SharedPreferences early
  String deviceId = '';
  try {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? '13';
    }
  } catch (e) {
    debugPrint('Error getting device info on startup: $e');
  }
  if (deviceId.isNotEmpty) {
    await prefs.setString('device_id', deviceId);
  }

  // Retrieve and store location params early if already permitted
  String lt = '';
  String ln = '';
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        Position? lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          lt = lastKnown.latitude.toString();
          ln = lastKnown.longitude.toString();
        }
      }
    }
  } catch (e) {
    debugPrint('Error getting location on startup: $e');
  }
  if (lt.isNotEmpty) await prefs.setString('lt', lt);
  if (ln.isNotEmpty) await prefs.setString('ln', ln);

  debugPrint('=========================================');
  debugPrint('[App Startup] Configured Version: $appVer');
  debugPrint('[App Startup] Stored Device ID: $deviceId');
  debugPrint('[App Startup] Stored Coordinates: lt=$lt, ln=$ln');
  debugPrint('=========================================');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: ThemeManager.isDarkNotifier,
          builder: (context, isDark, child) {
            return MaterialApp(
              title: 'True Loan',
              debugShowCheckedModeBanner: false,
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                physics: const ClampingScrollPhysics(),
              ),
              themeMode: ThemeMode.light,
              theme: ThemeData(
                brightness: Brightness.light,
                useMaterial3: true,
                scaffoldBackgroundColor: const Color(0xFFF5F6FA),
              ),
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}


