import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tm/login/login_screen.dart';
import 'package:tm/theme_manager.dart';

class GuestRestrictionDialog extends StatelessWidget {
  const GuestRestrictionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      elevation: 8,
      backgroundColor: context.cardBg,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Blue Shield Lock Circle Icon
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: context.isDarkMode ? const Color(0xFF1E2B4A) : const Color(0xFFEFF6FF), // Soft light blue #EFF6FF
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_rounded,
                color: const Color(0xFF004AC6), // Primary Blue #004AC6
                size: 28.w,
              ),
            ),
            SizedBox(height: 20.h),
            // Title
            Text(
              'Access Restricted',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: context.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            // Subtitle description
            Text(
              'Please log in to your account to post requirements, connect with lenders, and receive loan offers.',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: context.subTextColor,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            // Cancel and Login Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.subTextColor,
                        side: BorderSide(color: context.borderColor, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004AC6), // Primary Blue #004AC6
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
