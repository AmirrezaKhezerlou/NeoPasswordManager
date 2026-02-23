import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final errorColor = const Color(0xFFFF3B30);

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: backgroundColor.withOpacity(0.8),
        border: null,
        middle: Text(
          'weak_passwords_title'.tr,
          style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w700),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: errorColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: errorColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(CupertinoIcons.shield_slash_fill, color: errorColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'weak_passwords_warning'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: errorColor,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Obx(
                    () => controller.weakPasswords.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_shield_fill,
                        size: 70,
                        color: CupertinoColors.systemGreen.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_weak_passwords'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: onSurfaceColor.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'all_passwords_strong'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: onSurfaceColor.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.weakPasswords.length,
                  itemBuilder: (context, index) {
                    final password = controller.weakPasswords[index];
                    return WeakPasswordListItemCupertino(
                      password: password,
                      controller: controller,
                      surfaceColor: surfaceColor,
                      onSurfaceColor: onSurfaceColor,
                      primaryColor: primaryColor,
                      errorColor: errorColor,
                    );
                  },
                ),
              ),
            ),
          ],
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
  final Color primaryColor;
  final Color errorColor;

  const WeakPasswordListItemCupertino({
    super.key,
    required this.password,
    required this.controller,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.primaryColor,
    required this.errorColor,
  });

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength(password.password);
    final strengthColor = _getStrengthColor(strength);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => controller.showEditSheet(context, password),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: errorColor.withOpacity(0.2), width: 1),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(CupertinoIcons.exclamationmark_shield_fill, color: errorColor, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          password.label ?? 'no_label'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: onSurfaceColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          password.password,
                          style: TextStyle(
                            fontSize: 13,
                            color: errorColor.withOpacity(0.8),
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Transform.flip(
                    flipX: isRtl,
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      size: 14,
                      color: onSurfaceColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: strength / 5,
                        backgroundColor: onSurfaceColor.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getStrengthText(strength).tr,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: strengthColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStrengthColor(int strength) {
    if (strength <= 2) return const Color(0xFFFF3B30);
    if (strength <= 3) return const Color(0xFFFF9500);
    return const Color(0xFF34C759);
  }

  String _getStrengthText(int strength) {
    if (strength <= 1) return 'strength_very_weak';
    if (strength <= 2) return 'strength_weak';
    if (strength <= 3) return 'strength_medium';
    return 'strength_moderate';
  }

  int _calculateStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*()]').hasMatch(password)) score++;
    return score.clamp(1, 5);
  }
}