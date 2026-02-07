import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../dashboard/view/dashboard_page.dart';
import '../views/passcode_setup_page.dart';
import '../views/passcode_verify_page.dart';

class PasscodeController extends GetxController {
  final RxString storedPasscode = ''.obs;
  final RxList<String> inputDigits = <String>[].obs;
  final RxString tempPasscode = ''.obs;
  final RxString statusMessage = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool biometricEnabled = false.obs;

  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late final LocalAuthentication auth;

  @override
  void onInit() {
    super.onInit();
    if (!Platform.isWindows && !Platform.isLinux) {
      auth = LocalAuthentication();
    }
    _init();
  }

  Future<void> _init() async {
    storedPasscode.value = await storage.read(key: 'app_passcode') ?? '';
    biometricEnabled.value =
        (await storage.read(key: 'biometric_enabled')) == 'true';
    isLoading.value = false;
  }

  bool get hasPasscode => storedPasscode.isNotEmpty;

  void addDigit(String digit) {
    if (inputDigits.length >= 4) return;
    inputDigits.add(digit);
    statusMessage.value = '';
    if (inputDigits.length == 4) _processInput();
  }

  void deleteLastDigit() {
    if (inputDigits.isNotEmpty) {
      inputDigits.removeLast();
      statusMessage.value = '';
    }
  }

  void clearInput() {
    inputDigits.clear();
    statusMessage.value = '';
  }

  Future<void> _processInput() async {
    final input = inputDigits.join();
    final isSetting = !hasPasscode;

    if (isSetting) {
      if (tempPasscode.value.isEmpty) {
        tempPasscode.value = input;
        clearInput();
        statusMessage.value = 'Re-enter your passcode';
        return;
      }

      if (input != tempPasscode.value) {
        tempPasscode.value = '';
        clearInput();
        _error('Passcodes do not match');
        return;
      }

      storedPasscode.value = input;
      await storage.write(key: 'app_passcode', value: input);

      if (!Platform.isWindows && !Platform.isLinux) {
        try {
          if (await auth.canCheckBiometrics && await auth.isDeviceSupported()) {
            biometricEnabled.value = true;
            await storage.write(key: 'biometric_enabled', value: 'true');
          }
        } catch (_) {}
      }

      tempPasscode.value = '';
      Get.offAll(() => const DashboardPage());
      return;
    }

    if (input == storedPasscode.value) {
      Get.offAll(() => const DashboardPage());
    } else {
      clearInput();
      _error('Incorrect passcode');
    }
  }

  Future<void> smartLogin() async {
    if (!hasPasscode) {
      await startSettingPasscode();
      return;
    }
    await verifyPasscode();
  }

  Future<bool> attemptBiometricAuth() async {
    if (Platform.isWindows || Platform.isLinux) return false;
    if (!biometricEnabled.value) return false;
    try {
      final success = await auth.authenticate(
        localizedReason: 'Unlock with fingerprint',
        biometricOnly: true,
      );
      if (success) {
        Get.offAll(() => const DashboardPage());
      }
      return success;
    } catch (_) {
      return false;
    }
  }

  Future<void> startSettingPasscode() async {
    tempPasscode.value = '';
    clearInput();
    await Get.to(() => const PasscodeSetupPage());
  }

  Future<void> verifyPasscode() async {
    clearInput();
    await Get.to(() => const PasscodeVerifyPage());
  }

  Future<void> removePasscode() async {
    await storage.delete(key: 'app_passcode');
    await storage.delete(key: 'biometric_enabled');
    storedPasscode.value = '';
    biometricEnabled.value = false;
  }

  void _error(String message) {
    Get.dialog(
      barrierDismissible: false,
      CupertinoAlertDialog(
        title: const Text('Oops'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: Get.back,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}