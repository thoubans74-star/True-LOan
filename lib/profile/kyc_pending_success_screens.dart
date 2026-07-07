import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tm/api_services/kyc_pending_verify_api_service.dart';
import 'package:tm/home/loan_forms_screens.dart';
import 'package:tm/googleplay/playstore.dart';
import 'package:tm/theme_manager.dart';

class KycPendingScreen extends StatefulWidget {
  final bool isFromProfile;
  const KycPendingScreen({super.key, this.isFromProfile = false});

  @override
  State<KycPendingScreen> createState() => _KycPendingScreenState();
}

class _KycPendingScreenState extends State<KycPendingScreen> {
  Timer? _timer;
  String _message = 'Checking verification status...';

  @override
  void initState() {
    super.initState();
    _startStatusCheck();
    _checkPlaystoreAutoApproval();
  }

  Future<void> _checkPlaystoreAutoApproval() async {
    final bool autoApprove = await PlaystoreMock.shouldAutoApproveKyc();
    if (autoApprove) {
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _timer?.isActive == true) {
          _simulateApproval();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStatusCheck() {
    // Initial check
    _checkStatus();
    // Poll every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    final res = await KycPendingVerifyApiService.checkKycStatus();
    if (res != null) {
      final dynamic statusVal = res['status'];
      final int status = int.tryParse(statusVal?.toString() ?? '') ?? 0;

      if (status == 2) {
        _timer?.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => KycSuccessScreen(isFromProfile: widget.isFromProfile),
            ),
          );
        }
      } else if (status == 0) {
        _timer?.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Verification error. Please try again.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          setState(() {
            _message = 'Under review...';
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _simulateApproval() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => KycSuccessScreen(isFromProfile: widget.isFromProfile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldDarkBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldDarkBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.isDarkMode ? Colors.white : const Color(0xFF004AC6), size: 24.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'KYC Status',
          style: GoogleFonts.poppins(
            color: context.isDarkMode ? Colors.white : const Color(0xFF004AC6),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Hourglass / Pending Icon
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: context.isDarkMode ? const Color(0xFF2C2210) : const Color(0xFFFFFAEB),
                  shape: BoxShape.circle,
                  border: Border.all(color: context.isDarkMode ? const Color(0xFF5C472E) : const Color(0xFFFFDC8B), width: 2),
                ),
                child: Icon(
                  Icons.hourglass_empty_rounded,
                  color: context.isDarkMode ? const Color(0xFFFFB03A) : const Color(0xFFB4690E),
                  size: 48.w,
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'KYC Verification Pending',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'Your verification is under review. This process usually takes 12 to 24 hours. We will notify you once it is approved.',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: context.subTextColor,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),
              // Loading Spinner
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AC6)),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                _message,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: context.subTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class KycSuccessScreen extends StatelessWidget {
  final bool isFromProfile;
  const KycSuccessScreen({super.key, this.isFromProfile = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldDarkBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Checkmark Icon
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: context.isDarkMode ? const Color(0xFF102E20) : const Color(0xFFE8FDF0),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF10B981), width: 2),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                  size: 56.w,
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'KYC Verification Successful',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                isFromProfile
                    ? 'Your identity verification is successful. You can now access all app features.'
                    : 'Your identity verification is successful. You can now proceed to request your loan.',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: context.subTextColor,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (isFromProfile) {
                      // Navigate back to the Profile screen
                      Navigator.pop(context);
                    } else {
                      // Navigate to Need a Loan form
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NeedALoanFormScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AC6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isFromProfile ? 'Done' : 'Proceed to Loan Application',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
