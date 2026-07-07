import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static final ValueNotifier<bool> isDarkNotifier = ValueNotifier<bool>(false);

  static bool get isDark => isDarkNotifier.value;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isDarkNotifier.value = prefs.getBool('is_dark_mode') ?? false;
    } catch (e) {
      debugPrint('Error initializing ThemeManager: $e');
    }
  }

  static Future<void> toggleTheme(bool isDark) async {
    isDarkNotifier.value = isDark;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', isDark);
    } catch (e) {
      debugPrint('Error saving theme selection: $e');
    }
  }
}

extension ThemeContextExt on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  Color get pageBg => isDarkMode ? const Color(0xFF0F0F1A) : const Color(0xFFF5F6FA);
  Color get cardBg => isDarkMode ? const Color(0xFF1E1E2E) : Colors.white;
  Color get textColor => isDarkMode ? Colors.white : const Color(0xFF1E293B);
  Color get subTextColor => isDarkMode ? Colors.white70 : const Color(0xFF64748B);
  Color get dividerColor => isDarkMode ? const Color(0xFF2D2D3D) : const Color(0xFFE2E8F0);
  Color get inputBg => isDarkMode ? const Color(0xFF252535) : const Color(0xFFE9EDF5);
  Color get borderColor => isDarkMode ? const Color(0xFF2D2D3D) : const Color(0xFFE2E8F0);
  Color get iconColor => isDarkMode ? Colors.white70 : const Color(0xFF475569);
  Color get hintTextColor => isDarkMode ? const Color(0xFF6B7280) : const Color(0xFF6B7280);
  Color get dialogBg => isDarkMode ? const Color(0xFF1E1E2E) : Colors.white;
  Color get scaffoldDarkBg => isDarkMode ? const Color(0xFF0F0F1A) : Colors.white;

  /// Status bar style that matches the current theme
  SystemUiOverlayStyle get themedStatusBar => isDarkMode
      ? const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF004AC6),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        )
      : const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF004AC6),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        );

  /// For profile header which uses gradient
  SystemUiOverlayStyle get profileStatusBar => isDarkMode
      ? const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF1E3A8A),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        )
      : const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF1E3A8A),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        );

  /// Bottom nav bar background
  Color get navBarBg => isDarkMode ? const Color(0xFF1A1A2E) : Colors.white;
  Color get navBarBorder => isDarkMode ? const Color(0xFF2D2D3D) : const Color(0x1F000000);
  Color get navInactiveColor => isDarkMode ? const Color(0xFF6B7280) : const Color(0xFF94A3B8);

  /// Switch inactive track
  Color get switchInactiveTrack => isDarkMode ? const Color(0xFF3D3D4D) : const Color(0xFFE2E8F0);
}
