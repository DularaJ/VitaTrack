import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  static const _prefKey = 'isDarkMode';

  static Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_prefKey);
      if (isDark == null) {
        themeMode.value = ThemeMode.system;
      } else {
        themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (e) {
      // ignore and keep system
      themeMode.value = ThemeMode.system;
    }
  }

  static Future<void> setDark(bool dark) async {
    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, dark);
    } catch (e) {
      // ignore
    }
  }

  static Future<void> toggle() async {
    final current = themeMode.value;
    if (current == ThemeMode.dark) {
      await setDark(false);
    } else {
      await setDark(true);
    }
  }
}
