import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/modules/dashboard/controller/dashboard_controller.dart';
import '../../../services/storage_service/storage_manager.dart';
import '../controller/all_password_controller.dart';

class AllPasswordsPage extends StatelessWidget {
  const AllPasswordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();
    final controller = Get.put(AllPasswordsController(dashboardController));
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
          'all_passwords'.tr,
          style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w700),
        ),
        trailing: Obx(() {
          if (controller.isSelectionMode.value) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: controller.selectedPasswords.isNotEmpty ? controller.showDeleteConfirmation : null,
                  child: Icon(
                    CupertinoIcons.trash_fill,
                    color: controller.selectedPasswords.isNotEmpty ? errorColor : onSurfaceColor.withOpacity(0.2),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: controller.exitSelectionMode,
                  child: Text('done'.tr, style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
                ),
              ],
            );
          } else {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: controller.toggleSelectionMode,
              child: Text('edit'.tr, style: TextStyle(color: primaryColor)),
            );
          }
        }),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: CupertinoSearchTextField(
                controller: controller.searchController,
                onChanged: controller.filterPasswords,
                placeholder: 'search_passwords'.tr,
                backgroundColor: surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            if (controller.isSelectionMode.value)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${controller.selectedPasswords.length} ' + 'selected'.tr,
                      style: TextStyle(color: onSurfaceColor.withOpacity(0.6), fontWeight: FontWeight.w600),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () {
                        if (controller.selectedPasswords.length == dashboardController.passwords.length) {
                          controller.deselectAll();
                        } else {
                          controller.selectAll();
                        }
                      },
                      child: Text(
                        controller.selectedPasswords.length == dashboardController.passwords.length
                            ? 'deselect_all'.tr
                            : 'select_all'.tr,
                        style: TextStyle(fontSize: 14, color: primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Obx(() {
                final list = dashboardController.filteredPasswords.reversed.toList();
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.search, size: 60, color: onSurfaceColor.withOpacity(0.1)),
                        const SizedBox(height: 16),
                        Text(
                          'no_passwords_found'.tr,
                          style: TextStyle(fontSize: 17, color: onSurfaceColor.withOpacity(0.4)),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final password = list[index];
                    return PasswordListItemAllCupertino(
                      key: ValueKey('all_${password.id}'),
                      password: password,
                      dashboardController: dashboardController,
                      allPasswordsController: controller,
                      surfaceColor: surfaceColor,
                      onSurfaceColor: onSurfaceColor,
                      primaryColor: primaryColor,
                      errorColor: errorColor,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordListItemAllCupertino extends StatelessWidget {
  final PasswordModel password;
  final DashboardController dashboardController;
  final AllPasswordsController allPasswordsController;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final Color primaryColor;
  final Color errorColor;

  const PasswordListItemAllCupertino({
    super.key,
    required this.password,
    required this.dashboardController,
    required this.allPasswordsController,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.primaryColor,
    required this.errorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isObscured = dashboardController.obscurePassword[password.id] ?? true;
      final isSelected = allPasswordsController.selectedPasswords.contains(password);
      final isSelectionMode = allPasswordsController.isSelectionMode.value;
      final isWeak = dashboardController.weakPasswords.any((p) => p.id == password.id);
      final isRtl = Directionality.of(context) == TextDirection.rtl;

      return AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(bottom: 10),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: isSelectionMode
              ? () => allPasswordsController.toggleSelectPassword(password)
              : () => allPasswordsController.showPasswordItemSettings(context, password),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.08) : surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? primaryColor
                    : (isWeak ? errorColor.withOpacity(0.3) : onSurfaceColor.withOpacity(0.04)),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                if (isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      isSelected ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                      color: isSelected ? primaryColor : onSurfaceColor.withOpacity(0.2),
                      size: 24,
                    ),
                  ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isWeak ? errorColor.withOpacity(0.1) : primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      isWeak ? CupertinoIcons.exclamationmark_shield_fill : CupertinoIcons.shield_fill,
                      color: isWeak ? errorColor : primaryColor,
                      size: 24,
                    ),
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
                            color: isSelected ? primaryColor : onSurfaceColor
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isObscured ? '••••••••' : password.password,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: isObscured ? null : 'Courier',
                          color: isObscured ? onSurfaceColor.withOpacity(0.4) : primaryColor,
                          fontWeight: isObscured ? FontWeight.bold : FontWeight.w600,
                          letterSpacing: isObscured ? 1.2 : 0,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                if (!isSelectionMode)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minSize: 36,
                        onPressed: () => dashboardController.toggleObscure(password.id),
                        child: Icon(
                          isObscured ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill,
                          color: onSurfaceColor.withOpacity(0.3),
                          size: 20,
                        ),
                      ),
                      Transform.flip(
                        flipX: isRtl,
                        child: Icon(
                            CupertinoIcons.chevron_right,
                            size: 14,
                            color: onSurfaceColor.withOpacity(0.2)
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}