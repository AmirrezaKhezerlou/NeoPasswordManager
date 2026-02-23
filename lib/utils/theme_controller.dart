import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _key = 'user_theme_mode';

  final Rx<ThemeMode> _userSelectedMode = ThemeMode.light.obs;
  final Rx<ThemeMode> _effectiveThemeMode = ThemeMode.light.obs;

  Rx<Rx<ThemeMode>> get themeMode => _effectiveThemeMode.obs;
  Rx<Rx<ThemeMode>> get userMode => _userSelectedMode.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserPreference();
  }

  Future<void> _loadUserPreference() async {
    final String? savedMode = await _storage.read(key: _key);
    if (savedMode != null) {
      _userSelectedMode.value = ThemeMode.values.firstWhere(
            (e) => e.name == savedMode,
        orElse: () => ThemeMode.light,
      );
    } else {
      _userSelectedMode.value = ThemeMode.light;
    }
    _calculateEffectiveMode();
  }

  void _calculateEffectiveMode() {
    _effectiveThemeMode.value = _userSelectedMode.value;
    update();
  }

  void toggleTheme() {
    if (_userSelectedMode.value == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _userSelectedMode.value = mode;
    await _storage.write(key: _key, value: mode.name);
    _calculateEffectiveMode();
  }
}