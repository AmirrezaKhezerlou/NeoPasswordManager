import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/modules/dashboard/controller/dashboard_controller.dart';
import 'package:password_manager/services/storage_service/storage_manager.dart';

class AdvancedPasswordSheet {
  final TextEditingController labelController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool includeLowercase = true;
  bool includeUppercase = true;
  bool includeNumbers = true;
  bool includeSymbols = true;
  int passwordLength = 12;
  String? _initialPassword;

  AdvancedPasswordSheet({String? initialPassword}) {
    _initialPassword = initialPassword;
    if (_initialPassword != null) {
      passwordController.text = _initialPassword!;
    }
  }

  String _generatePassword() {
    String chars = '';
    if (includeLowercase) chars += 'abcdefghijklmnopqrstuvwxyz';
    if (includeUppercase) chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (includeNumbers) chars += '0123456789';
    if (includeSymbols) chars += '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    if (chars.isEmpty) return '';
    final random = Random();
    String result = List.generate(passwordLength, (index) => chars[random.nextInt(chars.length)]).join();
    final List<String> requiredTypes = [];
    if (includeLowercase) requiredTypes.add('a');
    if (includeUppercase) requiredTypes.add('A');
    if (includeNumbers) requiredTypes.add('0');
    if (includeSymbols) requiredTypes.add('!');
    for (var type in requiredTypes) {
      bool hasChar = false;
      switch (type) {
        case 'a': hasChar = RegExp(r'[a-z]').hasMatch(result); break;
        case 'A': hasChar = RegExp(r'[A-Z]').hasMatch(result); break;
        case '0': hasChar = RegExp(r'\d').hasMatch(result); break;
        case '!': hasChar = RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]').hasMatch(result); break;
      }
      if (!hasChar) {
        int pos = random.nextInt(result.length);
        String newChar = '';
        switch (type) {
          case 'a': newChar = String.fromCharCode(97 + random.nextInt(26)); break;
          case 'A': newChar = String.fromCharCode(65 + random.nextInt(26)); break;
          case '0': newChar = random.nextInt(10).toString(); break;
          case '!': newChar = '!@#\$%^&*()_+-=[]{}|;:,.<>?'.split('')[random.nextInt('!@#\$%^&*()_+-=[]{}|;:,.<>?'.length)]; break;
        }
        result = result.substring(0, pos) + newChar + result.substring(pos + 1);
      }
    }
    return result;
  }

  int _calculateStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]').hasMatch(password)) score++;
    return score;
  }

  void _showCupertinoAlert(BuildContext context, String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('ok'.tr),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _onSuccess() {
    // To be implemented
  }

  void show(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext ctx) {
        bool visiblePass = false;
        int tabIndex = 0;
        final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
        final backgroundColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
        final cardColor = isDark ? const Color(0xFF2C2C2E) : CupertinoColors.white;
        final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
        final labelColor = isDark ? CupertinoColors.systemGrey : CupertinoColors.secondaryLabel;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final strength = _calculateStrength(passwordController.text);
            final strengthColor = strength < 2 ? CupertinoColors.systemRed : strength < 4 ? CupertinoColors.activeOrange : CupertinoColors.activeGreen;

            return AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuad,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        Container(width: 36, height: 5, decoration: BoxDecoration(color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFC7C7CC), borderRadius: BorderRadius.circular(2.5))),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          child: Column(
                            children: [
                              Text('add_new_password_title'.tr, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  children: [
                                    CupertinoTextField(
                                      controller: labelController,
                                      placeholder: 'label_placeholder'.tr,
                                      padding: const EdgeInsets.all(16),
                                      prefix: Padding(padding: const EdgeInsets.only(left: 16), child: Icon(CupertinoIcons.tag_fill, color: primaryColor, size: 20)),
                                      decoration: const BoxDecoration(color: Colors.transparent),
                                    ),
                                    Divider(height: 1, thickness: 0.5, indent: 52, color: isDark ? Colors.white10 : Colors.black12),
                                    CupertinoTextField(
                                      controller: passwordController,
                                      obscureText: !visiblePass,
                                      onChanged: (_) => setState(() {}),
                                      placeholder: 'password'.tr,
                                      padding: const EdgeInsets.all(16),
                                      prefix: Padding(padding: const EdgeInsets.only(left: 16), child: Icon(CupertinoIcons.lock_fill, color: primaryColor, size: 20)),
                                      suffix: CupertinoButton(
                                        padding: const EdgeInsets.only(right: 8),
                                        onPressed: () => setState(() => visiblePass = !visiblePass),
                                        child: Icon(visiblePass ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill, color: labelColor, size: 18),
                                      ),
                                      decoration: const BoxDecoration(color: Colors.transparent),
                                    ),
                                  ],
                                ),
                              ),
                              if (passwordController.text.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: strength / 5,
                                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                                    valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                                    minHeight: 4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    _getStrengthLabel(strength),
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: strengthColor),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              CupertinoSlidingSegmentedControl<int>(
                                groupValue: tabIndex,
                                backgroundColor: isDark ? Colors.black26 : const Color(0xFFE3E3E8),
                                onValueChanged: (v) => setState(() {
                                  tabIndex = v!;
                                  if (v == 1) passwordController.text = _generatePassword();
                                }),
                                children: {0: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text('manual'.tr, style: const TextStyle(fontSize: 14))), 1: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text('generate'.tr, style: const TextStyle(fontSize: 14)))},
                              ),
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 300),
                                crossFadeState: tabIndex == 1 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                firstChild: const SizedBox(width: double.infinity),
                                secondChild: Column(
                                  children: [
                                    const SizedBox(height: 24),
                                    Container(
                                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                                      child: Column(
                                        children: [
                                          _buildModernToggle('lowercase'.tr, includeLowercase, (v) => setState(() { includeLowercase = v; passwordController.text = _generatePassword(); }), isDark),
                                          _buildModernDivider(isDark),
                                          _buildModernToggle('uppercase'.tr, includeUppercase, (v) => setState(() { includeUppercase = v; passwordController.text = _generatePassword(); }), isDark),
                                          _buildModernDivider(isDark),
                                          _buildModernToggle('numbers'.tr, includeNumbers, (v) => setState(() { includeNumbers = v; passwordController.text = _generatePassword(); }), isDark),
                                          _buildModernDivider(isDark),
                                          _buildModernToggle('symbols'.tr, includeSymbols, (v) => setState(() { includeSymbols = v; passwordController.text = _generatePassword(); }), isDark),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                                      child: Row(
                                        children: [
                                          Icon(CupertinoIcons.textformat_size, color: primaryColor, size: 20),
                                          const SizedBox(width: 12),
                                          Text(passwordLength.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          Expanded(
                                            child: CupertinoSlider(
                                              min: 4, max: 30,
                                              value: passwordLength.toDouble(),
                                              onChanged: (v) => setState(() { passwordLength = v.round(); passwordController.text = _generatePassword(); }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () => setState(() => passwordController.text = _generatePassword()),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(CupertinoIcons.refresh, size: 16), const SizedBox(width: 6), Text('regenerate'.tr, style: const TextStyle(fontSize: 14))]),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: CupertinoButton.filled(
                                  onPressed: () => _savePassword(context),
                                  child: Text('save_password'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernToggle(String title, bool value, ValueChanged<bool> onChanged, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          CupertinoSwitch(value: value, onChanged: onChanged, activeColor: const Color(0xFF34C759)),
        ],
      ),
    );
  }

  Widget _buildModernDivider(bool isDark) => Divider(height: 1, thickness: 0.5, indent: 16, color: isDark ? Colors.white10 : Colors.black12);

  String _getStrengthLabel(int score) {
    if (score <= 1) return 'strength_very_weak'.tr;
    if (score == 2) return 'strength_weak'.tr;
    if (score == 3) return 'strength_medium'.tr;
    if (score == 4) return 'strength_good'.tr;
    return 'strength_strong'.tr;
  }

  Future<void> _savePassword(BuildContext context) async {
    if (passwordController.text.isEmpty) {
      _showCupertinoAlert(context, 'error'.tr, 'password_empty_message'.tr);
      return;
    }
    final newModel = PasswordModel(
      password: passwordController.text,
      label: labelController.text.isEmpty ? null : labelController.text,
      creationDate: DateTime.now(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    await PasswordDatabase.instance.addPassword(newModel);
    Get.find<DashboardController>().fetchAndInitializePasswords();
    Navigator.of(context).pop();
    _onSuccess();
  }
}