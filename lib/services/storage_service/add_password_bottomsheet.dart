import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/modules/dashboard/controller/dashboard_controller.dart';
import 'package:password_manager/services/storage_service/storage_manager.dart';

class AdvancedPasswordSheet {
  final TextEditingController labelController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
    String generated = List.generate(passwordLength, (index) => chars[random.nextInt(chars.length)]).join();

    final List<String> requiredTypes = [];
    if (includeLowercase) requiredTypes.add('a');
    if (includeUppercase) requiredTypes.add('A');
    if (includeNumbers) requiredTypes.add('0');
    if (includeSymbols) requiredTypes.add('!');

    String result = generated;
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

  String _getStrengthLabel(int score) {
    if (score <= 1) return 'Very Weak';
    if (score == 2) return 'Weak';
    if (score == 3) return 'Medium';
    if (score == 4) return 'Good';
    return 'Strong';
  }

  void show(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext ctx) {
        bool visiblePass = false;
        int tabIndex = _initialPassword != null ? 0 : 0;

        final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
        final backgroundColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
        final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
        final onSurfaceColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E);
        final surfaceColor = backgroundColor;
        final errorColor = const Color(0xFFFF3B30);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            if (tabIndex == 1) {
              passwordController.text = _generatePassword();
            }

            return Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFC7C7CC),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  'Add New Password',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: onSurfaceColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              CupertinoTextField(
                                controller: labelController,
                                placeholder: 'e.g., Gmail, My Bank App',
                                prefix: Icon(CupertinoIcons.tag, color: primaryColor),
                                placeholderStyle: TextStyle(color: onSurfaceColor.withOpacity(0.5)),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                style: TextStyle(color: onSurfaceColor),
                              ),
                              const SizedBox(height: 20),
                              CupertinoSlidingSegmentedControl<int>(
                                groupValue: tabIndex,
                                onValueChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      tabIndex = value;
                                      if (value == 1) {
                                        passwordController.text = _generatePassword();
                                      }
                                    });
                                  }
                                },
                                children: const {
                                  0: Text('Manual'),
                                  1: Text('Generate'),
                                },
                              ),
                              const SizedBox(height: 20),
                              CupertinoTextField(
                                controller: passwordController,
                                obscureText: !visiblePass,
                                onChanged: (text) {
                                  if (tabIndex == 0) {
                                    setState(() {});
                                  }
                                },
                                placeholder: tabIndex == 0
                                    ? 'Enter your password'
                                    : 'Generated password',
                                prefix: Icon(CupertinoIcons.lock, color: primaryColor),
                                suffix: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(() => visiblePass = !visiblePass);
                                  },
                                  child: Icon(
                                    visiblePass ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                                    color: primaryColor,
                                  ),
                                ),
                                placeholderStyle: TextStyle(color: onSurfaceColor.withOpacity(0.5)),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                style: TextStyle(color: onSurfaceColor),
                              ),
                              const SizedBox(height: 10),
                              if (passwordController.text.isNotEmpty)
                                Row(
                                  children: List.generate(5, (index) {
                                    final isActive = index < _calculateStrength(passwordController.text);
                                    final color = isActive
                                        ? (index < 2 ? errorColor : index < 4 ? Colors.orange : Colors.green)
                                        : onSurfaceColor.withOpacity(0.1);
                                    return Expanded(
                                      child: Container(
                                        height: 4,
                                        margin: const EdgeInsets.only(right: 2),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              if (passwordController.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Text(
                                    _getStrengthLabel(_calculateStrength(passwordController.text)),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _calculateStrength(passwordController.text) < 2
                                          ? errorColor
                                          : _calculateStrength(passwordController.text) < 4
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                              if (tabIndex == 1) ...[
                                const SizedBox(height: 20),
                                Text(
                                  'Password Requirements',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: onSurfaceColor,
                                  ),
                                ),
                                _buildToggleRow(
                                  context: context,
                                  title: 'Lowercase',
                                  value: includeLowercase,
                                  onChanged: (v) {
                                    setState(() {
                                      includeLowercase = v!;
                                      passwordController.text = _generatePassword();
                                    });
                                  },
                                  isDark: isDark,
                                ),
                                _buildToggleRow(
                                  context: context,
                                  title: 'Uppercase',
                                  value: includeUppercase,
                                  onChanged: (v) {
                                    setState(() {
                                      includeUppercase = v!;
                                      passwordController.text = _generatePassword();
                                    });
                                  },
                                  isDark: isDark,
                                ),
                                _buildToggleRow(
                                  context: context,
                                  title: 'Numbers',
                                  value: includeNumbers,
                                  onChanged: (v) {
                                    setState(() {
                                      includeNumbers = v!;
                                      passwordController.text = _generatePassword();
                                    });
                                  },
                                  isDark: isDark,
                                ),
                                _buildToggleRow(
                                  context: context,
                                  title: 'Symbols',
                                  value: includeSymbols,
                                  onChanged: (v) {
                                    setState(() {
                                      includeSymbols = v!;
                                      passwordController.text = _generatePassword();
                                    });
                                  },
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.textformat_size, color: primaryColor),
                                    const SizedBox(width: 8),
                                    Text('Length: $passwordLength', style: TextStyle(color: onSurfaceColor)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: CupertinoSlider(
                                        min: 4,
                                        max: 30,
                                        value: passwordLength.toDouble(),
                                        onChanged: (value) {
                                          setState(() {
                                            passwordLength = value.round();
                                            passwordController.text = _generatePassword();
                                          });
                                        },
                                        activeColor: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                CupertinoButton.filled(
                                  onPressed: () {
                                    setState(() {
                                      passwordController.text = _generatePassword();
                                    });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(CupertinoIcons.shuffle, size: 20),
                                      SizedBox(width: 8),
                                      Text('Regenerate', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: CupertinoButton.filled(
                                  onPressed: () => _savePassword(context, setState, errorColor, onSurfaceColor),
                                  color: primaryColor,
                                  child: const Text('Save Password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(height: 20),
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

  Widget _buildToggleRow({
    required BuildContext context,
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: CupertinoListTile(
        leading: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF),
        ),
        title: Text(title, style: TextStyle(color: isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E))),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Future<void> _savePassword(BuildContext context, StateSetter setState, Color errorColor, Color onSurfaceColor) async {
    if (passwordController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Password cannot be empty.', backgroundColor: errorColor, colorText: Colors.white);
      return;
    }

    final dbInstance = PasswordDatabase.instance;
    final newModel = PasswordModel(
      password: passwordController.text,
      label: labelController.text.isEmpty ? null : labelController.text,
      creationDate: DateTime.now(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    await dbInstance.addPassword(newModel);
    DashboardController dashboardController = Get.find();
    dashboardController.fetchAndInitializePasswords();
    Navigator.of(context).pop();
    Get.snackbar(
      'Success',
      'Password saved successfully!',
      backgroundColor: const Color(0xFFD9F9D9),
      colorText: const Color(0xFF007AFF),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}