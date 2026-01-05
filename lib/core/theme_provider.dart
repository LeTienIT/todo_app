import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_todo_app/core/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeNotifier extends StateNotifier<AppThemeMode> {
  static const String _prefsKey = 'app_theme_mode';

  ThemeNotifier() : super(AppThemeMode.system) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getString(_prefsKey);

    if (savedValue != null) {
      try {
        state = AppThemeMode.values.firstWhere(
              (e) => e.toString() == savedValue,
        );
      } catch (_) {
        state = AppThemeMode.system;
      }
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.toString());
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

final appThemeDataProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeProvider);
  final platformBrightness = PlatformDispatcher.instance.platformBrightness;
  return AppTheme.getTheme(mode, platformBrightness);
});