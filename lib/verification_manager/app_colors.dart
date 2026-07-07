import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:tm/theme_manager.dart';

/// Centralized design tokens extracted from the reference screenshots.
/// Keep this file in sync if the design changes — every screen imports it.
class AppColors {
  AppColors._();

  static bool get isDark => ThemeManager.isDarkNotifier.value;

  // ---- Header / Navy ----
  static const Color navyDark = Color(0xFF00065E); // header gradient start
  static const Color navyMid = Color(0xFF0B1B6B); // header gradient end
  static Color get navyCard => isDark ? const Color(0xFF1E293B) : const Color(0xFF11245F); // dark card bg (visit detail)
  static Color get navyPillBg => isDark ? const Color(0xFF334155) : const Color(0xFF293A72); // pill bg on dark card

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
  static Color get greenLightBg => isDark ? const Color(0xFF0F3D23) : const Color(0xFFE5F8F1);
  static const Color greenText = Color(0xFF0E9F6E);

  // ---- Pink / Magenta (Support button) ----
  static const Color pinkStart = Color(0xFFE84FA0);
  static const Color pinkEnd = Color(0xFFB23BD8);

  // ---- Status colors ----
  static const Color red = Color(0xFFE53E3E);
  static Color get redLightBg => isDark ? const Color(0xFF4A1D1D) : const Color(0xFFFCE9EA);
  static const Color orange = Color(0xFFF59E0B);
  static Color get orangeLightBg => isDark ? const Color(0xFF4A371D) : const Color(0xFFFDF3E3);
  static const Color amberPriority = Color(0xFFD97706);

  // ---- Neutrals ----
  static Color get pageBg => isDark ? const Color(0xFF121212) : const Color(0xFFF7F8FA);
  static Color get cardBg => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  static Color get cardBorder => isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE7E9EE);
  static Color get textDark => isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1B2138);
  static Color get textGrey => isDark ? const Color(0xFF94A3B8) : const Color(0xFF8A8F9C);
  static Color get textGreyLight => isDark ? const Color(0xFF475569) : const Color(0xFFB0B4BE);
  static Color get inputBorder => isDark ? const Color(0xFF334155) : const Color(0xFFCBD3E1);
  static Color get tagBg => isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F2F6);
  static Color get infoBannerBg => isDark ? const Color(0xFF1E293B) : const Color(0xFFECF1FF);

  // ---- Gradients ----
  static LinearGradient headerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyDark, navyMid],
  );

  static LinearGradient appBarGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0B1B6B), Color(0xFF1A56DB)],
  );

  static LinearGradient totalAssignedGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [totalAssignedCardStart, totalAssignedCardEnd],
  );

  static LinearGradient greenBannerGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [greenBannerStart, greenBannerEnd],
  );

  static LinearGradient pinkButtonGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pinkStart, pinkEnd],
  );

  static LinearGradient greenButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: const [Color(0xFF1AC58F), greenDark],
  );
}

/// Common text styles reused across screens.
class AppText {
  AppText._();

  static const String fontFamily = 'Roboto'; // swap for your app's font

  static TextStyle get h1White => TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle get h2 => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle get body => TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textGrey,
  );

  static TextStyle get label => TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textGrey,
    letterSpacing: 0.4,
  );
}
