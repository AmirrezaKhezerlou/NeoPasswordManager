import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import '../../main.dart';

class AppSecurityService with WidgetsBindingObserver {
  static final AppSecurityService _instance = AppSecurityService._internal();
  factory AppSecurityService() => _instance;
  AppSecurityService._internal();

  DateTime? _appPausedTime;
  static const int _backgroundThresholdSeconds = 3;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    _secureAppPreview();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _appPausedTime = DateTime.now();
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      default:
        break;
    }
  }

  void _secureAppPreview() {
    if (GetPlatform.isAndroid || GetPlatform.isIOS) {
      FlutterWindowManagerPlus.addFlags(FlutterWindowManagerPlus.FLAG_SECURE);
    }
  }

  void _handleAppResumed() {
    if (_appPausedTime == null) return;

    final elapsed = DateTime.now().difference(_appPausedTime!);
    _appPausedTime = null;

    if (elapsed.inSeconds >= _backgroundThresholdSeconds) {
      _requirePasscode();
    }
  }

  void _requirePasscode() {

    Get.offAll(() => const PasscodeGateKeeper());
  }
}