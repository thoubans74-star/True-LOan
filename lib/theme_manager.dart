import 'package:flutter/material.dart';
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
}
