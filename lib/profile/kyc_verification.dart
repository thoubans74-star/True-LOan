import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tm/theme_manager.dart';
import 'package:tm/api_services/kyc_verification_api_service.dart';
import 'package:tm/api_services/kyc_pending_verify_api_service.dart';
import 'package:tm/profile/kyc_pending_success_screens.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  final TextEditingController _panController = TextEditingController();
  String? _panError;
  bool _submitting = false;
  bool _isValidPan = false;
  bool _checkingStatus = true;

  @override
  void initState() {
    super.initState();
    _checkKycStatusOnInit();
  }

  Future<void> _checkKycStatusOnInit() async {
    try {
      final res = await KycPendingVerifyApiService.checkKycStatus();
      if (res != null) {
        final dynamic statusVal = res['status'];
        final int status = int.tryParse(statusVal?.toString() ?? '') ?? 0;

        if (status == 2) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const KycSuccessScreen(isFromProfile: true)),
            );
            return;
          }
        } else if (status == 3) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const KycPendingScreen(isFromProfile: true)),
            );
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking KYC status on init: $e');
    }
    if (mounted) {
      setState(() {
        _checkingStatus = false;
      });
    }
  }

  @override
  void dispose() {
    _panController.dispose();
    super.dispose();
  }

  void _validatePan(String value) {
    final pan = value.trim().toUpperCase();
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    setState(() {
      _isValidPan = panRegex.hasMatch(pan);
      if (pan.isEmpty) {
        _panError = null;
      } else if (pan.length == 10) {
        if (!_isValidPan) {
          _panError = 'Invalid PAN format (e.g. ABCDE1234F)';
        } else {
          _panError = null;
        }
      } else {
        _panError = null;
      }
    });
  }

  Future<void> _onSubmit() async {
    final pan = _panController.text.trim().toUpperCase();
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    if (!panRegex.hasMatch(pan)) {
      setState(() {
        _panError = 'Invalid PAN format (e.g. ABCDE1234F)';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _panError = null;
    });

    final res = await KycVerificationApiService.submitKyc(
      panCard: pan,
      aadharCard: '',
      bankAccount: '',
    );

    setState(() {
      _submitting = false;
    });

    if (mounted) {
      if (res != null && (res['status'] == 1 || res['status']?.toString() == '1')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const KycPendingScreen(isFromProfile: true)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res?['message'] ?? 'Failed to submit verification. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldDarkBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldDarkBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.isDarkMode ? Colors.white : const Color(0xFF004AC6), size: 24.w),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'KYC Verification',
          style: GoogleFonts.poppins(
            color: context.isDarkMode ? Colors.white : const Color(0xFF004AC6),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _checkingStatus
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AC6)),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Why KYC? Lavender container (matches screenshot tone exactly!)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: context.isDarkMode ? const Color(0xFF1E1A3A) : const Color(0xFFF9F5FF), // Light purple/lavender
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: context.isDarkMode ? const Color(0xFF3E2A5D) : const Color(0xFFE9D7FE), width: 1.5),
                        ),
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Yellow Lightbulb Icon
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: Text(
                                '💡',
                                style: TextStyle(fontSize: 24.sp),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Why KYC?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: context.textColor, // Dark grey
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'KYC (Know Your Customer) is the process of verifying a customer\'s identity to prevent fraud and ensure legal compliance.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w400,
                                      color: context.subTextColor,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Document Header
                      Text(
                        'KYC Documentation',
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Enter PAN Number',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: context.textColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: _panError != null
                                ? const Color(0xFFEF4444)
                                : (context.isDarkMode ? context.borderColor : const Color(0xFFBDD8FF)),
                            width: 1.2,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          controller: _panController,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [PanTextInputFormatter()],
                          onChanged: _validatePan,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: context.textColor,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter 10-digit PAN (e.g. ABCDE1234F)',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF94A3B8),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_panError != null) ...[
                        SizedBox(height: 6.h),
                        Text(
                          _panError!,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Section
              Padding(
                padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
                child: Column(
                  children: [
                    Text(
                      'Your data is secure and used only for KYC verification',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: context.subTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: (_isValidPan && !_submitting) ? _onSubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004AC6),
                          disabledBackgroundColor: const Color(0xFF004AC6).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          elevation: 0,
                        ),
                        child: _submitting
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Submit Verification',
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
            ],
          ),
        ),
      ),
    );
  }
}

class PanTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final buffer = StringBuffer();
    int acceptedBeforeCursor = 0;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final currentLength = buffer.length;
      bool isValid = false;

      if (currentLength < 5) {
        if (RegExp(r'[a-zA-Z]').hasMatch(char)) {
          buffer.write(char.toUpperCase());
          isValid = true;
        }
      } else if (currentLength < 9) {
        if (RegExp(r'[0-9]').hasMatch(char)) {
          buffer.write(char);
          isValid = true;
        }
      } else if (currentLength == 9) {
        if (RegExp(r'[a-zA-Z]').hasMatch(char)) {
          buffer.write(char.toUpperCase());
          isValid = true;
        }
      }

      if (isValid && i < newValue.selection.end) {
        acceptedBeforeCursor++;
      }
    }

    final newText = buffer.toString();
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: acceptedBeforeCursor),
    );
  }
}

class KycVerificationBottomSheet extends StatefulWidget {
  const KycVerificationBottomSheet({super.key});

  @override
  State<KycVerificationBottomSheet> createState() => _KycVerificationBottomSheetState();
}

class _KycVerificationBottomSheetState extends State<KycVerificationBottomSheet> {
  final TextEditingController _panController = TextEditingController();
  String? _panError;
  bool _submitting = false;
  bool _isValidPan = false;

  @override
  void dispose() {
    _panController.dispose();
    super.dispose();
  }

  void _validatePan(String value) {
    final pan = value.trim().toUpperCase();
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    setState(() {
      _isValidPan = panRegex.hasMatch(pan);
      if (pan.isEmpty) {
        _panError = null;
      } else if (pan.length == 10) {
        if (!_isValidPan) {
          _panError = 'Invalid PAN format (e.g. ABCDE1234F)';
        } else {
          _panError = null;
        }
      } else {
        _panError = null;
      }
    });
  }

  Future<void> _onSubmit() async {
    final pan = _panController.text.trim().toUpperCase();
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    if (!panRegex.hasMatch(pan)) {
      setState(() {
        _panError = 'Invalid PAN format (e.g. ABCDE1234F)';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _panError = null;
    });

    final res = await KycVerificationApiService.submitKyc(
      panCard: pan,
      aadharCard: '',
      bankAccount: '',
    );

    setState(() {
      _submitting = false;
    });

    if (mounted) {
      if (res != null && (res['status'] == 1 || res['status']?.toString() == '1')) {
        Navigator.pop(context); // Close bottom sheet
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KycPendingScreen(isFromProfile: false)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res?['message'] ?? 'Failed to submit verification. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KYC Verification',
                  style: GoogleFonts.poppins(
                    color: context.textColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: context.isDarkMode ? Colors.white70 : const Color(0xFF64748B), size: 24.w),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Why KYC? Lavender container (matches screenshot tone exactly!)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.isDarkMode ? const Color(0xFF1E1A3A) : const Color(0xFFF9F5FF), // Light purple/lavender
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: context.isDarkMode ? const Color(0xFF3E2A5D) : const Color(0xFFE9D7FE), width: 1.5),
              ),
              padding: EdgeInsets.all(16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Yellow Lightbulb Icon
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      '💡',
                      style: TextStyle(fontSize: 21.sp),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Why KYC?',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: context.textColor, // Dark grey
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'KYC (Know Your Customer) is the process of verifying a customer\'s identity to prevent fraud and ensure legal compliance.',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: context.subTextColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            Text(
              'KYC Documentation',
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'PAN Number',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: context.textColor,
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: _panError != null
                      ? const Color(0xFFEF4444)
                      : (context.isDarkMode ? context.borderColor : const Color(0xFFBDD8FF)),
                  width: 1.2,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _panController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [PanTextInputFormatter()],
                onChanged: _validatePan,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: context.textColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter 10-digit PAN (e.g. ABCDE1234F)',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_panError != null) ...[
              SizedBox(height: 6.h),
              Text(
                _panError!,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: (_isValidPan && !_submitting) ? _onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AC6),
                  disabledBackgroundColor: const Color(0xFF004AC6).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                ),
                child: _submitting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Submit Verification',
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
