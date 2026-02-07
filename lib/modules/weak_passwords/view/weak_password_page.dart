// weak_passwords_page.dart
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:password_manager/modules/dashboard/controller/dashboard_controller.dart';

import '../../../services/storage_service/storage_manager.dart';
import '../controller/weak_password_controller.dart';

class WeakPasswordsPage extends StatelessWidget {
  const WeakPasswordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();
    final controller = Get.put(WeakPasswordsController(dashboardController));
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final onSurfaceColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E);
    final errorColor = const Color(0xFFFF3B30);
    final warningColor = const Color(0xFFFF9500);

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: backgroundColor,
        middle: const Text('Weak Passwords'),
        previousPageTitle: '',
        trailing: null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: errorColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.exclamationmark_triangle, color: errorColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'These passwords are weak and should be updated for better security.',
                        style: TextStyle(fontSize: 14, color: errorColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(
                      () => controller.weakPasswords.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.check_mark_circled,
                          size: 60,
                          color: const Color(0xFF007AFF).withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No weak passwords found',
                          style: TextStyle(fontSize: 17, color: onSurfaceColor.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Great! All your passwords are strong.',
                          style: TextStyle(fontSize: 15, color: onSurfaceColor.withOpacity(0.3)),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    itemCount: controller.weakPasswords.length,
                    itemBuilder: (context, index) {
                      final password = controller.weakPasswords[index];
                      return WeakPasswordListItemCupertino(
                        password: password,
                        controller: controller,
                        surfaceColor: surfaceColor,
                        onSurfaceColor: onSurfaceColor,
                        errorColor: errorColor,
                        warningColor: warningColor,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeakPasswordListItemCupertino extends StatelessWidget {
  final PasswordModel password;
  final WeakPasswordsController controller;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final Color errorColor;
  final Color warningColor;

  const WeakPasswordListItemCupertino({
    Key? key,
    required this.password,
    required this.controller,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.errorColor,
    required this.warningColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final passwordStrength = _calculatePasswordStrength(password.password);
    final strengthColor = _getStrengthColor(passwordStrength);
    final strengthText = _getStrengthText(passwordStrength);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: errorColor.withOpacity(0.3), width: 1.5),
      ),
      child: CupertinoListTile(
        leading: Icon(CupertinoIcons.lock, color: errorColor, size: 24),
        title: Text(
          password.label ?? 'No label',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              password.password,
              style: TextStyle(fontSize: 13, color: errorColor, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Strength: $strengthText',
                  style: TextStyle(fontSize: 11, color: strengthColor, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    final isActive = index < passwordStrength;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.only(right: 2),
                        decoration: BoxDecoration(
                          color: isActive ? strengthColor : onSurfaceColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => controller.showEditSheet(context, password),
          child: Icon(CupertinoIcons.pencil, color: onSurfaceColor.withOpacity(0.6), size: 22),
        ),
      ),
    );
  }

  Color _getStrengthColor(int strength) {
    if (strength <= 2) return const Color(0xFFFF3B30); // red
    if (strength <= 3) return const Color(0xFFFF9500); // orange
    return const Color(0xFF30D158); // green
  }

  String _getStrengthText(int strength) {
    if (strength <= 2) return 'Very Weak';
    if (strength <= 3) return 'Weak';
    return 'Moderate';
  }

  int _calculatePasswordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    return (score / 2).ceil().clamp(1, 5);
  }
}