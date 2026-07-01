import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showKycDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const KycVerificationDialog(),
  );
}

class KycVerificationDialog extends StatelessWidget {
  const KycVerificationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 40,
              offset: Offset(0, 16),
            ),
          ],
        ),
        // Reduced top padding from 28 → 14 to uplift all content
        padding: EdgeInsets.fromLTRB(24, 14, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Close button with #F2F4F6 circular background ────────────
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 20.w,
                    color: Color(0xFF434652),
                  ),
                ),
              ),
            ),

            // ── Shield PNG image, uplifted ────────────────────────────────
            Transform.translate(
              offset:  Offset(0, -14),
              child: Image.asset(
                'assets/home/shield.png',
                width: 36.w,
                height: 45.h,
                fit: BoxFit.contain,
              ),
            ),

            // Tight gap after image (already uplifted by Transform)
            SizedBox(height: 0.h),

            Text(
              'Verify Your Identity',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF191C1E),
              ),
            ),

            SizedBox(height: 10.h),

            Text(
              'To unlock all features and start matching with lenders, please complete your KYC verification.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),

            SizedBox(height: 22.h),

            // ── Complete KYC button ───────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Navigate to KYC screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Complete KYC Now',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // ── Maybe Later ───────────────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                'Maybe Later',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: const Color(0xFF434652),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
