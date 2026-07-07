import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tm/api_services/kyc_pending_verify_api_service.dart';
import 'package:tm/profile/kyc_verification.dart';
import 'package:tm/profile/kyc_pending_success_screens.dart';
import 'package:tm/home/loan_forms_screens.dart';
import 'package:flutter/services.dart';
import 'package:tm/theme_manager.dart';

class CreateAdScreen extends StatefulWidget {
  final int initialSelectedType;
  const CreateAdScreen({super.key, this.initialSelectedType = -1});

  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  String _selectedRole = 'Select Role';
  bool _checkingKyc = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedType == 0) {
      _selectedRole = 'Borrower';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleBorrowerFlow();
      });
    } else if (widget.initialSelectedType == 1) {
      _selectedRole = 'Lender';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleLenderFlow();
      });
    }
  }

  void _showRoleSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: context.dividerColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Select Application Role',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: context.textColor,
                ),
              ),
              SizedBox(height: 20.h),

              // Option 1: Borrower
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedRole = 'Borrower');
                  _handleBorrowerFlow();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: context.borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: context.isDarkMode ? const Color(0xFF1E2B4A) : const Color(0xFFE8F2FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          color: const Color(0xFF1A6AE8),
                          size: 20.w,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Borrower',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: context.textColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Need a loan for personal, business, home or vehicle requirements',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: context.subTextColor,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: const Color(0xFF94A3B8),
                        size: 24.w,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // Option 2: Lender
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedRole = 'Lender');
                  _handleLenderFlow();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: context.borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: context.isDarkMode ? const Color(0xFF0E3D26) : const Color(0xFFE8FDF0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: const Color(0xFF10B981),
                          size: 20.w,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lender',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: context.textColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Fund borrowers and gain interest returns securely',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: context.subTextColor,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: const Color(0xFF94A3B8),
                        size: 24.w,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleBorrowerFlow() async {
    setState(() {
      _checkingKyc = true;
    });

    final res = await KycPendingVerifyApiService.checkKycStatus();
    
    setState(() {
      _checkingKyc = false;
    });

    if (mounted) {
      if (res != null) {
        final dynamic statusVal = res['status'];
        final int status = int.tryParse(statusVal?.toString() ?? '') ?? 0;

        if (status == 2) {
          // status = 2: KYC verified successfully, proceed directly to Need a Loan form
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const NeedALoanFormScreen()),
          );
        } else if (status == 3) {
          // status = 3: KYC pending review, redirect to pending screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const KycPendingScreen(isFromProfile: false)),
          );
        } else if (status == 1) {
          // status = 1: PAN not submitted, open KYC verification bottom sheet
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            builder: (context) => const KycVerificationBottomSheet(),
          );
        } else {
          // status = 0 (user not found) or error: Show message and open bottom sheet fallback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'KYC verification required.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            builder: (context) => const KycVerificationBottomSheet(),
          );
        }
      } else {
        // Fallback to KYC verification bottom sheet if API check fails
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          builder: (context) => const KycVerificationBottomSheet(),
        );
      }
    }
  }

  void _handleLenderFlow() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GiveALoanFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.themedStatusBar,
      child: Scaffold(
      backgroundColor: context.scaffoldDarkBg,
      body: Column(
        children: [
          // ── App Header (Blue AppBar) ───────────────────────────────────
          Container(
            color: const Color(0xFF004AC6),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24.w,
                      ),
                    ),
                    Text(
                      'Loan Services',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content Area ───────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Your Application Role',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Choose whether you want to apply for a loan as a borrower or fund requirements as a lender.',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: context.subTextColor,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Dropdown Selector Trigger
                      GestureDetector(
                        onTap: _showRoleSelectionSheet,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFF004AC6), width: 1.2),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                color: const Color(0xFF004AC6),
                                size: 22.w,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                _selectedRole,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: _selectedRole == 'Select Role'
                                      ? context.subTextColor
                                      : context.textColor,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: context.subTextColor,
                                size: 22.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 48.h),

                      // Smart Loan Matching Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: context.isDarkMode ? context.inputBg : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 56.w,
                              height: 56.w,
                              decoration: BoxDecoration(
                                color: context.isDarkMode ? const Color(0xFF1E2B4A) : const Color(0xFFE8F2FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.psychology_alt_rounded,
                                color: const Color(0xFF1A6AE8),
                                size: 28.w,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Smart Loan Matching',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textColor,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Our platform instantly matches verified borrowers with verified lenders to ensure quick, transparent, and seamless loan agreements.',
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: context.subTextColor,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // KYC Status API Check Loading Overlay
                if (_checkingKyc)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AC6)),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Checking KYC status...',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: context.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
