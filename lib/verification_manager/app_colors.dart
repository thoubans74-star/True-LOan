import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

/// Centralized design tokens extracted from the reference screenshots.
/// Keep this file in sync if the design changes — every screen imports it.
class AppColors {
  AppColors._();

  // ---- Header / Navy ----
  static const Color navyDark = Color(0xFF00065E); // header gradient start
  static const Color navyMid = Color(0xFF0B1B6B); // header gradient end
  static const Color navyCard = Color(0xFF11245F); // dark card bg (visit detail)
  static const Color navyPillBg = Color(0xFF293A72); // pill bg on dark card

  // ---- Primary blue (buttons, accents) ----
  static const Color primaryBlue = Color(0xFF1A56DB);
  static const Color primaryBlueDark = Color(0xFF0B3FA8);
  static const Color totalAssignedCardStart = Color(0xFF004AC6);
  static const Color totalAssignedCardEnd = Color(0xFF0064E0);

  // ---- Greens ----
  static const Color green = Color(0xFF13B981);
  static const Color greenDark = Color(0xFF0F8460);
  static const Color greenBannerStart = Color(0xFF12DBA0);
  static const Color greenBannerEnd = Color(0xFF107959);
  static const Color greenLightBg = Color(0xFFE5F8F1);
  static const Color greenText = Color(0xFF0E9F6E);

  // ---- Pink / Magenta (Support button) ----
  static const Color pinkStart = Color(0xFFE84FA0);
  static const Color pinkEnd = Color(0xFFB23BD8);

  // ---- Status colors ----
  static const Color red = Color(0xFFE53E3E);
  static const Color redLightBg = Color(0xFFFCE9EA);
  static const Color orange = Color(0xFFF59E0B);
  static const Color orangeLightBg = Color(0xFFFDF3E3);
  static const Color amberPriority = Color(0xFFD97706);

  // ---- Neutrals ----
  static const Color pageBg = Color(0xFFF7F8FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE7E9EE);
  static const Color textDark = Color(0xFF1B2138);
  static const Color textGrey = Color(0xFF8A8F9C);
  static const Color textGreyLight = Color(0xFFB0B4BE);
  static const Color inputBorder = Color(0xFFCBD3E1);
  static const Color tagBg = Color(0xFFF1F2F6);
  static const Color infoBannerBg = Color(0xFFECF1FF);

  // ---- Gradients ----
  static LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyDark, navyMid],
  );

  static LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0B1B6B), Color(0xFF1A56DB)],
  );

  static LinearGradient totalAssignedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [totalAssignedCardStart, totalAssignedCardEnd],
  );

  static LinearGradient greenBannerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [greenBannerStart, greenBannerEnd],
  );

  static LinearGradient pinkButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pinkStart, pinkEnd],
  );

  static LinearGradient greenButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1AC58F), greenDark],
  );
}

/// Common text styles reused across screens.
class AppText {
  AppText._();

  static const String fontFamily = 'Roboto'; // swap for your app's font

  static TextStyle h1White = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  static TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textGrey,
  );

  static TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textGrey,
    letterSpacing: 0.4,
  );
}
