import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();

  }

  void toggleTheme() {
    if (themeMode.value == ThemeMode.light) {
      themeMode(ThemeMode.dark);
    } else if (themeMode.value == ThemeMode.dark) {
      themeMode(ThemeMode.light);
    } else {
      themeMode(ThemeMode.light);
    }
    update();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode(mode);
    update();
  }
}
