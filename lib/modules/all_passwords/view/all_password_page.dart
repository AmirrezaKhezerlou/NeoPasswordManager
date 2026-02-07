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
        backgroundColor: backgroundColor,
        middle: const Text('All Passwords'),
        previousPageTitle: '',
        trailing: Obx(() {
          if (controller.isSelectionMode.value) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.selectedPasswords.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text('${controller.selectedPasswords.length}', style: TextStyle(color: errorColor)),
                  ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: controller.selectedPasswords.isNotEmpty ? controller.showDeleteConfirmation : null,
                  child: Icon(CupertinoIcons.trash, color: controller.selectedPasswords.isNotEmpty ? errorColor : onSurfaceColor.withOpacity(0.3), size: 24),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (controller.selectedPasswords.length == dashboardController.passwords.length) {
                      controller.deselectAll();
                    } else {
                      controller.selectAll();
                    }
                  },
                  child: Icon(
                    controller.selectedPasswords.length == dashboardController.passwords.length
                        ? CupertinoIcons.check_mark_circled_solid
                        : CupertinoIcons.circle,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: controller.exitSelectionMode,
                  child: const Icon(CupertinoIcons.clear, size: 24),
                ),
              ],
            );
          } else {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: controller.toggleSelectionMode,
              child: Icon(CupertinoIcons.pencil, color: primaryColor, size: 24),
            );
          }
        }),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoTextField(
                controller: controller.searchController,
                onChanged: controller.filterPasswords,
                placeholder: 'Search passwords',
                prefix: Icon(CupertinoIcons.search, color: primaryColor),
                placeholderStyle: TextStyle(color: onSurfaceColor.withOpacity(0.5)),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                style: TextStyle(color: onSurfaceColor),
              ),
            ),
            Expanded(
              child: Obx(() {
                final list = dashboardController.filteredPasswords;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.lock_open, size: 60, color: onSurfaceColor.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('No passwords found', style: TextStyle(fontSize: 17, color: onSurfaceColor.withOpacity(0.5))),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final password = list.reversed.toList()[index];
                    final isObscured = dashboardController.obscurePassword[password.id] ?? true;
                    final isSelected = controller.selectedPasswords.contains(password);
                    final isSelectionMode = controller.isSelectionMode.value;

                    return PasswordListItemAllCupertino(
                      key: Key('item_${password.id}_$isSelectionMode'),
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
    Key? key,
    required this.password,
    required this.dashboardController,
    required this.allPasswordsController,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.primaryColor,
    required this.errorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isObscured = dashboardController.obscurePassword[password.id] ?? true;
      final isSelected = allPasswordsController.selectedPasswords.contains(password);
      final isSelectionMode = allPasswordsController.isSelectionMode.value;
      final isWeak = dashboardController.weakPasswords.any((p) => p.id == password.id);

      return GestureDetector(
        onTap: isSelectionMode
            ? () => allPasswordsController.toggleSelectPassword(password)
            : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.1) : surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : (isWeak ? errorColor.withOpacity(0.3) : Colors.transparent),
              width: isSelected ? 2 : (isWeak ? 1.5 : 0),
            ),
          ),
          child: Row(
            children: [
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    isSelected ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                    color: isSelected ? primaryColor : onSurfaceColor.withOpacity(0.3),
                    size: 24,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(CupertinoIcons.lock, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            password.label ?? 'No label',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isWeak)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: errorColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Weak',
                              style: TextStyle(
                                fontSize: 11,
                                color: errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isObscured ? '••••••••' : password.password,
                      style: TextStyle(
                        fontSize: 13,
                        color: isObscured ? onSurfaceColor.withOpacity(0.5) : primaryColor,
                        fontWeight: isObscured ? FontWeight.normal : FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!isSelectionMode)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        dashboardController.copyToClipboard(context, password.password);
                      },
                      child: Icon(CupertinoIcons.doc_on_doc, color: onSurfaceColor.withOpacity(0.5), size: 20),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        dashboardController.toggleObscure(password.id);
                      },
                      child: Icon(
                        isObscured ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                        color: onSurfaceColor.withOpacity(0.5),
                        size: 20,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        allPasswordsController.showPasswordItemSettings(context, password);
                      },
                      child: Icon(CupertinoIcons.ellipsis, color: onSurfaceColor.withOpacity(0.5), size: 20),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }
}