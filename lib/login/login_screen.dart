import 'package:flutter_screenutil/flutter_screenutil.dart';
// ignore_for_file: unused_import, unused_local_variable

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_auth/smart_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../new_home/new_home_screen.dart';
import '../home/main_navigation.dart';
import '../api_services/login_api_service.dart';
import '../verification_manager/verification_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _showOtpSection = false;
  bool _isLoading = false;
  String? _fToken;
  int _otpSessionCount = 0;
  String? _pendingOtp;

  Timer? _resendTimer;
  int _secondsRemaining = 30;
  bool _canResend = false;

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          _resendTimer?.cancel();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _printAppSignature();
  }

  /// Prints the live app signature to logcat so you can verify it
  /// matches the hash appended at the end of your backend OTP SMS.
  Future<void> _printAppSignature() async {
    try {
      final result = await SmartAuth.instance.getAppSignature();
      String sig = result.data ?? 'unavailable';
      // Strip surrounding brackets if present
      sig = sig.replaceAll('[', '').replaceAll(']', '').trim();
      debugPrint('\n╔══════════════════════════════════╗');
      debugPrint('║  APP SIGNATURE (add to SMS end)  ║');
      debugPrint('║  $sig  ║');
      debugPrint('╚══════════════════════════════════╝\n');
    } catch (e) {
      debugPrint('[SIG] Error getting signature: $e');
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<Map<String, String>> _getCurrentLocation() async {
    String lt = '11';
    String ln = '11';
    try {
      final prefs = await SharedPreferences.getInstance();
      lt = prefs.getString('lt') ?? '11';
      ln = prefs.getString('ln') ?? '11';

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
            await prefs.setString('lt', lt);
            await prefs.setString('ln', ln);
          }

          // Attempt to get fresh location with a longer timeout
          try {
            Position position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                timeLimit: Duration(seconds: 15),
              ),
            );
            lt = position.latitude.toString();
            ln = position.longitude.toString();

            await prefs.setString('lt', lt);
            await prefs.setString('ln', ln);
          } catch (e) {
            debugPrint(
              'Error getting fresh real-time location in login screen: $e',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting real-time location: $e');
    }
    return {'lt': lt, 'ln': ln};
  }

  Future<String> _getRealDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? storedId = prefs.getString('device_id');
      if (storedId != null && storedId != '13') {
        return storedId;
      }

      final deviceInfo = DeviceInfoPlugin();
      String deviceId = '13';
      if (!kIsWeb && Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (!kIsWeb && Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '13';
      }
      await prefs.setString('device_id', deviceId);
      return deviceId;
    } catch (e) {
      debugPrint('Error getting device ID in real time: $e');
      return '13';
    }
  }

  Future<String> _getRealAppSignature() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? storedSig = prefs.getString('app_signature');
      if (storedSig != null && storedSig != 'itufuifyfufu') {
        return storedSig;
      }

      String appSignature = 'itufuifyfufu';
      if (!kIsWeb) {
        final signatureResult = await SmartAuth.instance
            .getAppSignature()
            .timeout(
              const Duration(seconds: 2),
              onTimeout: () => SmartAuthResult<String>.canceled(),
            );
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
      }
      await prefs.setString('app_signature', appSignature);
      return appSignature;
    } catch (e) {
      debugPrint('Error getting app signature in real time: $e');
      return 'itufuifyfufu';
    }
  }

  Future<void> _startSmsListener() async {
    // Cancel any previous listeners before starting fresh
    try {
      await SmartAuth.instance.removeSmsRetrieverApiListener();
      await SmartAuth.instance.removeUserConsentApiListener();
    } catch (_) {}

    _otpController.clear();
    _pendingOtp = null;

    debugPrint('\n==============================');
    debugPrint('[OTP] SMS listener started');
    debugPrint('==============================\n');

    // ── 1. Try SMS Retriever API first (silent, needs hash in SMS) ──────────
    SmartAuth.instance
        .getSmsWithRetrieverApi()
        .timeout(
          const Duration(seconds: 90),
          onTimeout: () {
            debugPrint('[OTP] RetrieverApi TIMEOUT after 90s');
            return SmartAuthResult<SmartAuthSms>.canceled();
          },
        )
        .then((res) {
          debugPrint('[OTP] RetrieverApi response: hasData=${res.hasData}');
          if (res.hasData && res.data != null) {
            final rawSms = res.data!.sms;
            debugPrint('[OTP] RetrieverApi raw SMS: "$rawSms"');
            String? code = res.data!.code;
            debugPrint('[OTP] RetrieverApi parsed code field: $code');
            if (code == null || code.isEmpty) {
              final match = RegExp(r'\b(\d{6})\b').firstMatch(rawSms);
              code = match?.group(0);
              debugPrint('[OTP] RetrieverApi regex fallback code: $code');
            }
            if (code != null && mounted) {
              debugPrint('[OTP] ✅ RetrieverApi SUCCESS: $code');
              _onSmsCodeReceived(code);
            } else {
              debugPrint('[OTP] ❌ RetrieverApi: SMS received but code is null');
            }
          } else {
            debugPrint(
              '[OTP] ❌ RetrieverApi: no data (hash mismatch or unsupported)',
            );
          }
        })
        .catchError((e) {
          debugPrint('[OTP] ❌ RetrieverApi error: $e');
        });

    // ── 2. Try User Consent API in parallel (shows system dialog, no hash needed) ─
    SmartAuth.instance
        .getSmsWithUserConsentApi()
        .timeout(
          const Duration(seconds: 90),
          onTimeout: () {
            debugPrint('[OTP] UserConsentApi TIMEOUT after 90s');
            return SmartAuthResult<SmartAuthSms>.canceled();
          },
        )
        .then((res) {
          debugPrint('[OTP] UserConsentApi response: hasData=${res.hasData}');
          if (res.hasData && res.data != null) {
            final rawSms = res.data!.sms;
            debugPrint('[OTP] UserConsentApi raw SMS: "$rawSms"');
            String? code = res.data!.code;
            debugPrint('[OTP] UserConsentApi parsed code field: $code');
            if (code == null || code.isEmpty) {
              final match = RegExp(r'\b(\d{6})\b').firstMatch(rawSms);
              code = match?.group(0);
              debugPrint('[OTP] UserConsentApi regex fallback code: $code');
            }
            if (code != null && mounted) {
              debugPrint('[OTP] ✅ UserConsentApi SUCCESS: $code');
              _onSmsCodeReceived(code);
            } else {
              debugPrint(
                '[OTP] ❌ UserConsentApi: SMS received but code is null',
              );
            }
          } else {
            debugPrint('[OTP] ❌ UserConsentApi: user declined or no data');
          }
        })
        .catchError((e) {
          debugPrint('[OTP] ❌ UserConsentApi error: $e');
        });
  }

  /// Called by either API when a valid OTP code is extracted.
  void _onSmsCodeReceived(String code) {
    if (!mounted) return;
    debugPrint(
      '[OTP] _onSmsCodeReceived: code=$code, showOtpSection=$_showOtpSection',
    );

    // Ignore duplicate events if the OTP is already fully filled
    if (_otpController.text.length == 6) {
      debugPrint('[OTP] Code already filled, ignoring duplicate SMS event');
      return;
    }

    if (_showOtpSection) {
      _autofillOtpInstantly(code);
    } else {
      _pendingOtp = code;
      debugPrint(
        '[OTP] stored as _pendingOtp — will fill after OTP section appears',
      );
    }
  }

  /// Autofills the controller instantly to avoid key entry channel sync issues with the software keyboard,
  /// and triggers verification immediately.
  void _autofillOtpInstantly(String code) {
    if (!mounted) return;
    debugPrint('[OTP] Autofilling code instantly: $code');
    _otpController.text = code;
    _otpController.selection = TextSelection.collapsed(offset: code.length);
    _verifyOtp(code);
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Non-blocking location retrieval: load from cache instantly
      final prefs = await SharedPreferences.getInstance();
      final lt = prefs.getString('lt') ?? '11';
      final ln = prefs.getString('ln') ?? '11';

      // Refresh location in background
      _getCurrentLocation().catchError((e) {
        debugPrint('Background location error: $e');
        return {'lt': '11', 'ln': '11'};
      });

      final deviceId = await _getRealDeviceId();
      final appSignature = await _getRealAppSignature();

      final response = await http.post(
        Uri.parse('https://trueloan.ai.in/ai/api/m_api/'),
        body: {
          'cid': '21472147',
          'ln': ln,
          'lt': lt,
          'device_id': deviceId,
          'type': '1100',
          'mobile': phone,
          'app_signature': appSignature,
        },
      );

      if (!mounted) return;

      debugPrint('[API Response - Send OTP (1100)]: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final bool isSuccess =
            data['status'] == 'success' || data['error'] == false;

        if (isSuccess) {
          // Backend may return the token nested under "data" OR flat at the
          // top level (as confirmed by the actual login response shape).
          final resData = data['data'];
          String? token;
          if (resData is Map) {
            token =
                (resData['f_token'] ??
                        resData['token'] ??
                        resData['token_id'] ??
                        resData['verification_token'])
                    ?.toString();
          }
          token ??=
              data['f_token']?.toString() ??
              data['token']?.toString() ??
              data['token_id']?.toString();

          debugPrint('[OTP Token Extracted] token = $token');

          // Check for is_new_user from flat or nested response data
          final bool isNewUser = (data['is_new_user'] == true || data['is_new_user']?.toString() == 'true') ||
                                 (resData is Map && (resData['is_new_user'] == true || resData['is_new_user']?.toString() == 'true'));
          await prefs.setBool('is_new_user', isNewUser);
          if (token != null && token.isNotEmpty) {
            await prefs.setString('token', token);
          }
          debugPrint('[OTP sendOtp] Stored is_new_user = $isNewUser, token = $token');

          if (token == null || token.isEmpty) {
            // Don't silently fall back to a fake token — surface the failure
            // so it's obvious extraction failed instead of sending garbage
            // to the verify-OTP call.
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Could not retrieve verification token. Please try again.',
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          setState(() {
            _fToken = token;
            _showOtpSection = true;
            _otpSessionCount++;
          });
          _startResendTimer();

          _startSmsListener();

          if (_pendingOtp != null) {
            final codeToFill = _pendingOtp!;
            _pendingOtp = null;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _autofillOtpInstantly(codeToFill);
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final String errMsg =
              data['error_msg'] ?? data['message'] ?? 'Failed to send OTP';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errMsg), backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Server error (${response.statusCode}). Please try again later.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connection failed. Please check your internet connection: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOtp(String pin) async {
    if (_isLoading) return;
    if (pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_fToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification token missing. Please request a new OTP.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final lt = prefs.getString('lt') ?? '11';
      final ln = prefs.getString('ln') ?? '11';

      // Refresh location in background
      _getCurrentLocation().catchError((e) {
        debugPrint('Background location error: $e');
        return {'lt': '11', 'ln': '11'};
      });

      final deviceId = await _getRealDeviceId();

      final requestBody = {
        'cid': '21472147',
        'ln': ln,
        'lt': lt,
        'device_id': deviceId,
        'type': '1101',
        'mobile': _phoneController.text.trim(),
        'otp': pin,
        'token': _fToken!,
      };
      debugPrint('[API Request - Verify OTP (1101)] Body sent: $requestBody');

      final response = await http.post(
        Uri.parse('https://trueloan.ai.in/ai/api/m_api/'),
        body: requestBody,
      );

      if (!mounted) return;

      debugPrint('[API Response - Verify OTP (1101)]: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final bool isSuccess =
            data['status'] == 'success' || data['error'] == false;
        if (isSuccess) {
          // Backend may return the verified-user fields nested under "data"
          // OR flat at the top level — handle both shapes.
          final Map resData = (data['data'] is Map)
              ? data['data'] as Map
              : data;

          final String? userId = resData['user_id']?.toString();
          if (userId != null) {
            await prefs.setString('user_id', userId);
          }
          final String? tokenVal = (resData['token'] ?? resData['f_token'] ?? data['token'] ?? data['f_token'])?.toString() ?? _fToken;
          if (tokenVal != null && tokenVal.isNotEmpty) {
            await prefs.setString('token', tokenVal);
          }
          if (resData['name'] != null) {
            await prefs.setString('name', resData['name'].toString());
          }
          if (resData['mobile'] != null || resData['phone'] != null) {
            await prefs.setString(
              'mobile',
              (resData['mobile'] ?? resData['phone']).toString(),
            );
          }
          if (resData['email'] != null) {
            await prefs.setString('email', resData['email'].toString());
          }
          if (resData['profile_image'] != null) {
            await prefs.setString(
              'profile_image',
              resData['profile_image'].toString(),
            );
          }

          // Check is_new_user from response, falling back to previously stored value
          final bool isNewUser = (data['is_new_user'] == true || data['is_new_user']?.toString() == 'true') ||
                                 (resData['is_new_user'] == true || resData['is_new_user']?.toString() == 'true') ||
                                 (prefs.getBool('is_new_user') ?? false);
          await prefs.setBool('is_new_user', isNewUser);
          debugPrint('[OTP verifyOtp] Final stored is_new_user = $isNewUser');

          if (!mounted) return;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogCtx) => _OtpVerifiedDialog(
              onContinue: () {
                Navigator.pop(dialogCtx);
                if (mounted) {
                  setState(() {
                    _showOtpSection = false;
                    _otpController.clear();
                    _fToken = null;
                    _resendTimer?.cancel();
                  });

                  if (isNewUser) {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const NewHomeScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const MainNavigationScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  }
                }
              },
            ),
          );
        } else {
          if (!mounted) return;
          final String errMsg =
              data['error_msg'] ?? data['message'] ?? 'Verification failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errMsg), backgroundColor: Colors.red),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Server error (${response.statusCode}). Please try again later.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connection failed. Please check your internet connection: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final size = MediaQuery.of(context).size;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor =  Color(0xFF2563EB);

    final defaultPinTheme = PinTheme(
      width: 40.w,
      height: 40.h,
      textStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF2C2C2C),
        height: 1.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: activeColor.withValues(alpha: 0.3), width: 1.0),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: activeColor, width: 2.0),
        color: Colors.white,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: MediaQuery.of(context).viewInsets.bottom > 0
                  ? const ClampingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Custom Back Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: sw * 0.01,
                          top: sh * 0.032,
                          bottom: sh * 0.015,
                        ),
                        child: Image.asset(
                          'assets/login/login_back.png',
                          width: sw * 0.055,
                          height: sw * 0.055,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.01),

                    // Welcome title
                    Padding(
                      padding: EdgeInsets.only(left: sw * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to',
                            style: GoogleFonts.inriaSans(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w300,
                              color: activeColor,
                              height: 1.0,
                              letterSpacing: 0.0,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'True Loan',
                            style: GoogleFonts.inriaSans(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w700,
                              color: activeColor,
                              height: 1.0,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: sh * 0.03),
                    Transform.translate(
                      offset: Offset(0, sh * 0.005),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Login illustration
                          Center(
                            child: Image.asset(
                              'assets/login/Login (2).png',
                              width: sw * 0.65,
                              height: sh * 0.27,
                              fit: BoxFit.contain,
                            ),
                          ),

                          SizedBox(height: sh * 0.046),

                          // Phone Input Field
                          Transform.translate(
                            offset: const Offset(0, -15),
                            child: Center(
                              child: SizedBox(
                                width: sw * 0.778,
                                height: sh * 0.054,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:  Color(0xFF817979),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: sw * 0.04,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '+91',
                                        style: GoogleFonts.lato(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                          height: 1.0,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      SizedBox(width: sw * 0.045),
                                      Container(
                                        height: sh * 0.028,
                                        width: 1,
                                        color: const Color(0xFF979797),
                                      ),
                                      SizedBox(width: sw * 0.035),
                                      Expanded(
                                        child: TextField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          cursorColor: const Color(0xFF817979),
                                          cursorHeight: 18,
                                          maxLength: 10,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          style: GoogleFonts.lato(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF686363),
                                            letterSpacing: 0.0,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Enter Mobile Number',
                                            hintStyle: GoogleFonts.lato(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF686363),
                                              letterSpacing: 0.0,
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                            counterText: "",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: sh * 0.025),

                          // Send OTP Button
                          Center(
                            child: SizedBox(
                              width: sw * 0.778,
                              height: sh * 0.050,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _sendOtp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  disabledBackgroundColor: const Color(
                                    0xFF2563EB,
                                  ).withValues(alpha: 0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 20.w,
                                        height: 20.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'SEND OTP',
                                        style: GoogleFonts.lato(
                                          color: Colors.white,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700,
                                          height: 1.0,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          SizedBox(height: sh * 0.04),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: const Color(0xFFAAA5A5),
                                  thickness: 1.0,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.04,
                                ),
                                child: Text(
                                  'or continue with',
                                  style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: sw * 0.033,
                                    fontWeight: FontWeight.w500,
                                    height: 1.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: const Color(0xFFAAA5A5),
                                  thickness: 1.0,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: sh * 0.04),

                          // Guest Button
                          Center(
                            child: SizedBox(
                              width: sw * 0.778,
                              height: sh * 0.050,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                          ) => const NewHomeScreen(),
                                      transitionsBuilder:
                                          (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                            child,
                                          ) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOut;
                                            var tween = Tween(
                                              begin: begin,
                                              end: end,
                                            ).chain(CurveTween(curve: curve));
                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                      transitionDuration: const Duration(
                                        milliseconds: 400,
                                      ),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF2563EB),
                                  side: const BorderSide(
                                    color: Color(0xFF2563EB),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  'CONTINUE AS GUEST',
                                  style: GoogleFonts.lato(
                                    fontSize: sw * 0.0388,
                                    fontWeight: FontWeight.w700,
                                    height: 1.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: sh * 0.02),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Backdrop Overlay
          if (_showOtpSection)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showOtpSection = false;
                  _resendTimer?.cancel();
                });
              },
              child: Container(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.45),
              ),
            ),

          AnimatedPositioned(
            duration:  Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            bottom: _showOtpSection ? 0 : -size.height,
            left: 0.w,
            right: 0.w,
            child: Container(
              height: size.height * 0.38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(38.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                size.width * 0.06,
                size.height * 0.02,
                size.width * 0.06,
                size.height * 0.03,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Verify OTP title ───────────────────────
                    Padding(
                      padding: EdgeInsets.only(left: 28.0.w),
                      child: Text(
                        'verify otp',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.06,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C2C2C),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.012),

                    // ── OTP sent message ───────────────────────
                    Center(
                      child: SizedBox(
                        width: 310.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Waiting to automatically detect an OTP sent to',
                              style: GoogleFonts.poppins(
                                fontSize: 10.5.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w300,
                                height: 1.2,
                                letterSpacing: 0.0,
                                decorationColor: activeColor,
                              ),
                            ),
                            SizedBox(height: 8.0.h),
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5.sp,
                                  color: const Color(0xFF2C2C2C),
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                  letterSpacing: 0.0,
                                  decorationColor: activeColor,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        '+91 ${_phoneController.text.trim()}. ',
                                  ),
                                  TextSpan(
                                    text: 'Wrong Number ?',
                                    style: GoogleFonts.poppins(
                                      color: activeColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                      height: 1.2,
                                      letterSpacing: 0.0,
                                      decorationColor: activeColor,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        setState(() {
                                          _showOtpSection = false;
                                          _resendTimer?.cancel();
                                        });
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.028),

                    // ── PIN input ──────────────────────────────
                    Center(
                      child: SizedBox(
                        width: 310.w,
                        child: _showOtpSection
                            ? Pinput(
                                key: ValueKey(
                                  'pinput_session_$_otpSessionCount',
                                ),
                                controller: _otpController,
                                length: 6,
                                separatorBuilder: (index) =>
                                    SizedBox(width: 14.w),
                                defaultPinTheme: defaultPinTheme,
                                focusedPinTheme: focusedPinTheme,
                                onCompleted: (pin) {
                                  _verifyOtp(pin);
                                },
                                autofocus: _showOtpSection,
                              )
                            : SizedBox.shrink(),
                      ),
                    ),

                    SizedBox(height: size.height * 0.018),

                    // ── Resend row ─────────────────────────────
                    Center(
                      child: SizedBox(
                        width: 300.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: (_canResend && !_isLoading) ? _sendOtp : null,
                              child: Text(
                                'Resend OTP',
                                style: GoogleFonts.poppins(
                                  color: _canResend ? activeColor : Colors.grey.shade500,
                                  fontSize: 12.sp,
                                  fontWeight: _canResend ? FontWeight.w600 : FontWeight.w400,
                                  height: 1.0,
                                  decoration: _canResend ? TextDecoration.underline : TextDecoration.none,
                                  decorationStyle: TextDecorationStyle.solid,
                                ),
                              ),
                            ),
                            if (!_canResend)
                              Text(
                                '$_secondsRemaining Sec',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  height: 1.0,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.045),

                    // ── Verify & Continue button ───────────────
                    Center(
                      child: SizedBox(
                        width: 300.w,
                        height: 44.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeColor,
                            disabledBackgroundColor: activeColor.withValues(
                              alpha: 0.6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () => _verifyOtp(_otpController.text),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'VERIFY & CONTINUE',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.width * 0.0370,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFFFFE5),
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SmsRetrieverImpl implements SmsRetriever {
  const SmsRetrieverImpl(this.smartAuth);

  final SmartAuth smartAuth;

  @override
  Future<void> dispose() async {
    try {
      await smartAuth.removeSmsRetrieverApiListener();
    } catch (_) {}
    try {
      await smartAuth.removeUserConsentApiListener();
    } catch (_) {}
  }

  @override
  Future<String?> getSmsCode() async => null; // Not used — see _startSmsListener

  @override
  bool get listenForMultipleSms => false;
}

class _OtpVerifiedDialog extends StatelessWidget {
  final VoidCallback onContinue;
  const _OtpVerifiedDialog({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green Checkmark Icon Container
            Container(
              width: 56.w,
              height: 56.w,
              decoration: const BoxDecoration(
                color: Color(0xFFE8FDF0), // Soft green circle background
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: const Color(0xFF10B981), // Emerald Green
                size: 32.w,
              ),
            ),
            SizedBox(height: 20.h),
            // Title text
            Text(
              'OTP Verified Successfully',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            // Subtitle text description
            Text(
              'Your phone number has been authenticated. You can now access your dashboard.',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            // Solid Blue primary button
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), // Primary Blue
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
