import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Rx<Locale> currentLocale = const Locale('fa', 'IR').obs;
  final String _localeKey = 'user_locale';

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    final savedLocale = await _storage.read(key: _localeKey);
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      currentLocale.value = Locale(parts[0], parts.length > 1 ? parts[1] : '');
    }
    update();
  }

  Future<void> changeLocale(Locale locale) async {
    currentLocale.value = locale;
    await _storage.write(key: _localeKey, value: '${locale.languageCode}_${locale.countryCode}');
    Get.updateLocale(locale);
    update();
  }

  String get fontFamily {
    return currentLocale.value.languageCode == 'fa' ? 'modam' : 'poppins';
  }
}