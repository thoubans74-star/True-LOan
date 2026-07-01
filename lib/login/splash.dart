import 'package:tm/fast_page_route.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_auth/smart_auth.dart';
import 'package:tm/login/onboarding.dart';
import 'package:tm/home/main_navigation.dart';
import 'package:tm/new_home/new_home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tm/api_services/version_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    _initAppData();
  }

  Future<void> _initAppData() async {
    final startTime = DateTime.now();

    // Fetch and store location and device params
    await _fetchAndStoreData();

    // App Version update check
    final bool isUpdateRequired = await _checkAppVersionUpdate();
    if (isUpdateRequired) {
      return; // Stop flow and show update dialogue
    }

    final elapsed = DateTime.now().difference(startTime);
    final remaining = const Duration(milliseconds: 1900) - elapsed;

    if (remaining.isNegative) {
      await _routeUser();
    } else {
      await Future.delayed(remaining);
      await _routeUser();
    }
  }

  Future<bool> _checkAppVersionUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final String currentVer = packageInfo.buildNumber;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_version', currentVer);

      final updateModel = await VersionApiService.checkVersion(currentVer);
      if (updateModel != null) {
        debugPrint('=========================================');
        debugPrint('[Splash App Update check] parsed response:');
        debugPrint('  - error: ${updateModel.error}');
        debugPrint('  - status: ${updateModel.status}');
        debugPrint('  - update_required: ${updateModel.updateRequired}');
        debugPrint('  - current_version: ${updateModel.currentVersion}');
        debugPrint('  - latest_version: ${updateModel.latestVersion}');
        debugPrint('  - download_url: ${updateModel.downloadUrl}');
        debugPrint('  - message: ${updateModel.message}');
        debugPrint('  - uid: ${updateModel.uid}');
        debugPrint('=========================================');

        final String cur = updateModel.currentVersion;
        final String lat = updateModel.latestVersion;
        
        if (cur.isNotEmpty && lat.isNotEmpty && cur != lat) {
          if (!mounted) return false;
          _showUpdateDialog(updateModel.downloadUrl, cur, lat);
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error checking app version: $e');
    }
    return false;
  }

  void _showUpdateDialog(String downloadUrl, String current, String latest) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.system_update_rounded,
                      color: const Color(0xFF3B82F6),
                      size: 36.w,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'App Update Available',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'A new version of the app is available. Please update to continue using the application.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'v$current ➔ v$latest',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final Uri url = Uri.parse(downloadUrl.isNotEmpty 
                            ? downloadUrl 
                            : 'https://play.google.com/store/apps/details?id=com.trueguide.app');
                        try {
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        } catch (e) {
                          debugPrint('Error launching play store link: $e');
                        }
                      },
                      child: Text(
                        'Update Now',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _routeUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final String userId = prefs.getString('user_id') ?? '';
    final String token = prefs.getString('token') ?? '';
    final bool isNewUser = prefs.getBool('is_new_user') ?? false;
    
    if (userId.isNotEmpty && token.isNotEmpty) {
      if (isNewUser) {
        Navigator.of(context).pushReplacement(
          FastPageRoute(child: const NewHomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          FastPageRoute(child: const MainNavigationScreen()),
        );
      }
    } else {
      // Force onboarding/login if session is incomplete (e.g. no token)
      if (userId.isNotEmpty) {
        await prefs.clear();
      }
      Navigator.of(context).pushReplacement(
        FastPageRoute(child: const OnboardingScreen()),
      );
    }
  }

  Future<void> _fetchAndStoreData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Fetch Location
      String lt = '';
      String ln = '';
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (serviceEnabled) {
            // Get last known position first as an instantaneous fallback
            Position? lastKnown = await Geolocator.getLastKnownPosition();
            if (lastKnown != null) {
              lt = lastKnown.latitude.toString();
              ln = lastKnown.longitude.toString();
            }

            // Attempt to get fresh location with a longer timeout
            try {
              Position position = await Geolocator.getCurrentPosition(
                locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.low,
                  timeLimit: Duration(seconds: 15),
                ),
              );
              lt = position.latitude.toString();
              ln = position.longitude.toString();
            } catch (e) {
              debugPrint(
                'Error getting fresh location in splash, using last known: $e',
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Error getting location: $e');
      }

      // 2. Fetch Device ID
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
        debugPrint('Error getting device info: $e');
      }

      // 3. Fetch App Signature
      String appSignature = 'itufuifyfufu';
      try {
        final signatureResult = await SmartAuth.instance.getAppSignature();
        if (signatureResult.hasData && signatureResult.data != null) {
          String rawSignature = signatureResult.data!;
          if (rawSignature.startsWith('[') && rawSignature.endsWith(']')) {
            rawSignature = rawSignature.substring(1, rawSignature.length - 1);
          }
          if (rawSignature.contains(',')) {
            rawSignature = rawSignature.split(',').first.trim();
          }
          appSignature = rawSignature.trim();
        }
      } catch (e) {
        debugPrint('Error getting app signature: $e');
      }

      // Store in Shared Preferences
      if (lt.trim().isNotEmpty) {
        await prefs.setString('lt', lt.trim());
      } else {
        await prefs.remove('lt');
      }

      if (ln.trim().isNotEmpty) {
        await prefs.setString('ln', ln.trim());
      } else {
        await prefs.remove('ln');
      }

      if (deviceId.trim().isNotEmpty) {
        await prefs.setString('device_id', deviceId.trim());
      } else {
        await prefs.remove('device_id');
      }

      if (appSignature.trim().isNotEmpty) {
        await prefs.setString('app_signature', appSignature.trim());
      } else {
        await prefs.remove('app_signature');
      }

      debugPrint(
        'Stored in SharedPreferences: lt=$lt, ln=$ln, device_id=$deviceId, app_signature=$appSignature',
      );
    } catch (e) {
      debugPrint('Error in _fetchAndStoreData: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Responsive calculations based on standard layout (approx. 390x844 screen)
    final logoTextSpacing = screenHeight * 0.02; // ~16px
    final titleFontSize = screenWidth * 0.082; // ~32px
    final titleLetterSpacing = -screenWidth * 0.0027; // ~-1.05px
    final subtitleFontSize = screenWidth * 0.036; // ~14px
    final subtitleLetterSpacing = screenWidth * 0.0011; // ~0.45px
    final spacingUnderTitle = screenHeight * 0.01; // ~8px

    final bottomOffset = -screenHeight * 0.12; // ~-100px (Uplifted from -0.071)
    final barWidth = screenWidth * 0.72; // ~280px
    final barHeight = screenHeight * 0.007; // ~6px
    final barTextSpacing = screenHeight * 0.02; // ~16px
    final footerFontSize = screenWidth * 0.026; // ~10px
    final footerLetterSpacing = screenWidth * 0.0051; // ~2px
    final bottomMargin = screenHeight * 0.03; // ~24px

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.24,
            colors: [Color(0xFF0053DB), Color(0xFF004AC6)],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Spacer to push the logo and title to the middle
              const Spacer(flex: 3),

              // Logo Box
              Center(
                child: Transform.translate(
                  offset: const Offset(0, -20), // slight up that image to avoid disturbing the title letters
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0x01FFFFFF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/login/trueloan_logo.png',
                        fit: BoxFit.contain,
                        opacity: const AlwaysStoppedAnimation<double>(1.0),
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback in case of asset loading failure
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              size: 48,
                              color: Colors.blue,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Uplifted title and subtitle closer to the logo box
              SizedBox(height: logoTextSpacing),

              Transform.translate(
                offset: Offset(0, -screenHeight * 0.035),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title "TRUE  LOAN"
                    Text(
                      'TRUE LOAN',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          height: 52.5 / 42, // line-height: 52.5px
                          letterSpacing: titleLetterSpacing,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: spacingUnderTitle),

                    // Subtitle "Connecting Borrowers & Lenders"
                    Text(
                      'Connecting Borrowers & Lenders',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w400,
                          height: 28 / 18, // line-height: 28px
                          letterSpacing: subtitleLetterSpacing,
                          color: const Color(0x80DBE1FF), // #DBE1FFCC
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Spacer to push the bar and footer to the bottom
              const Spacer(flex: 3),

              // Uplift progress bar and footer vertically using Transform.translate
              Transform.translate(
                offset: Offset(0, bottomOffset),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Shimmering Progress Bar
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Container(
                          width: barWidth,
                          height: barHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(barHeight / 2),
                            gradient: LinearGradient(
                              begin: Alignment(
                                -3.0 + 4.0 * _controller.value,
                                0.0,
                              ),
                              end: Alignment(
                                -1.0 + 4.0 * _controller.value,
                                0.0,
                              ),
                              colors: const [
                                Color(0x1AFFFFFF), // rgba(255, 255, 255, 0.1)
                                Color(0x66FFFFFF), // rgba(255, 255, 255, 0.4)
                                Color(0x1AFFFFFF), // rgba(255, 255, 255, 0.1)
                              ],
                              stops: const [0.25, 0.50, 0.75],
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: barTextSpacing),

                    // Footer Text "SECURING CONNECTION"
                    Text(
                      'SECURING CONNECTION',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        textStyle: TextStyle(
                          fontSize: footerFontSize,
                          fontWeight: FontWeight.w400,
                          height: 15 / 10, // line-height: 15px
                          letterSpacing: footerLetterSpacing,
                          color: const Color(0x60FFFFFF), // #FFFFFF99
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: bottomMargin),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreenPlaceholder extends StatelessWidget {
  const HomeScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Login Screen Placeholder',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
