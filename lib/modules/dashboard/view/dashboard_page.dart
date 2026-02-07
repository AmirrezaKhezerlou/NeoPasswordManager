import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/modules/dashboard/controller/dashboard_controller.dart';
import 'package:password_manager/modules/dashboard/widgets/custom_appbar.dart';
import '../../../main.dart';
import '../../../services/storage_service/add_password_bottomsheet.dart';
import '../../../services/storage_service/storage_manager.dart';
import '../../../utils/consts.dart';
import '../../all_passwords/view/all_password_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final onSurfaceColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E);
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final errorColor = isDark ? const Color(0xFFFF453A) : const Color(0xFFFF3B30);


    WidgetsBinding.instance.addPostFrameCallback((_) {
      final handler = Get.find<SharedTextHandlerService>();

      if (handler.hasData) {
        AdvancedPasswordSheet(
          initialPassword: handler.take(),
        ).show(context);
      }
    });
    
    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CustomDashboardAppbarCupertino(
        onSettingsTap: controller.showSettingsSheet,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstVariables.mainPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                    () => SizedBox(
                  height: 130,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InfoSquareWidgetCupertino(
                        count: controller.savedPasswordsCount.value,
                        title: 'Passwords\nStored',
                        color: primaryColor,
                        surfaceColor: surfaceColor,
                        onSurfaceColor: onSurfaceColor,
                      ),
                      InfoSquareWidgetCupertino(
                        count: controller.compromisedPasswordsCount.value,
                        title: 'Weak\nPasswords',
                        color: errorColor,
                        surfaceColor: surfaceColor,
                        onSurfaceColor: onSurfaceColor,
                        onTap: controller.compromisedPasswordsCount.value > 0
                            ? controller.navigateToWeakPasswords
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CupertinoTextField(
                controller: controller.searchController,
                onChanged: controller.filterPasswords,
                placeholder: 'Search label',
                prefix: Icon(CupertinoIcons.search, color: primaryColor),
                placeholderStyle: TextStyle(color: onSurfaceColor.withOpacity(0.5)),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                style: TextStyle(color: onSurfaceColor),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: () => AdvancedPasswordSheet().show(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(CupertinoIcons.add, size: 20),
                      SizedBox(width: 8),
                      Text('Add New Password'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Passwords',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: onSurfaceColor,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Get.to(() => const AllPasswordsPage());
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(child: PasswordListViewWidgetCupertino(controller: controller)),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoSquareWidgetCupertino extends StatelessWidget {
  final int count;
  final String title;
  final Color color;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final VoidCallback? onTap;

  const InfoSquareWidgetCupertino({
    super.key,
    required this.count,
    required this.title,
    required this.color,
    required this.surfaceColor,
    required this.onSurfaceColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (Get.width - AppConstVariables.mainPadding * 3) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: onSurfaceColor.withOpacity(0.7),
              ),
            ),
            if (onTap != null && count > 0)
              Icon(
                CupertinoIcons.forward,
                size: 16,
                color: color.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }
}

class PasswordListItemCupertino extends StatelessWidget {
  final PasswordModel password;
  final bool isObscured;
  final VoidCallback onToggleObscure;
  final DashboardController dashboardController;
  final Color primaryColor;
  final Color onSurfaceColor;
  final Color surfaceColor;
  final Color errorColor;

  const PasswordListItemCupertino({
    Key? key,
    required this.password,
    required this.isObscured,
    required this.onToggleObscure,
    required this.dashboardController,
    required this.primaryColor,
    required this.onSurfaceColor,
    required this.surfaceColor,
    required this.errorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWeak = dashboardController.weakPasswords.any((p) => p.id == password.id);
    final borderColor = isWeak ? errorColor.withOpacity(0.3) : Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoListTile(
        leading: Icon(CupertinoIcons.lock, color: primaryColor, size: 24),
        title: Text(
          password.label ?? 'No label',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          isObscured ? '••••••••' : password.password,
          style: TextStyle(
            fontSize: 13,
            color: isObscured ? onSurfaceColor.withOpacity(0.5) : primaryColor,
            fontWeight: isObscured ? FontWeight.normal : FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onToggleObscure,
              child: Icon(
                isObscured ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                color: onSurfaceColor.withOpacity(0.5),
                size: 20,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => dashboardController.copyToClipboard(context, password.password),
              child: Icon(
                CupertinoIcons.doc_on_doc,
                color: onSurfaceColor.withOpacity(0.5),
                size: 20,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => dashboardController.showPasswordItemSettings(context, password),
              child: Icon(
                CupertinoIcons.ellipsis,
                color: onSurfaceColor.withOpacity(0.5),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordListViewWidgetCupertino extends StatefulWidget {
  final DashboardController controller;

  const PasswordListViewWidgetCupertino({Key? key, required this.controller}) : super(key: key);

  @override
  State<PasswordListViewWidgetCupertino> createState() => _PasswordListViewWidgetCupertinoState();
}

class _PasswordListViewWidgetCupertinoState extends State<PasswordListViewWidgetCupertino> {
  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final onSurfaceColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E);
    final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final errorColor = isDark ? const Color(0xFFFF453A) : const Color(0xFFFF3B30);

    return Obx(
          () => widget.controller.filteredPasswords.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.lock_open,
              size: 60,
              color: onSurfaceColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No passwords found',
              style: TextStyle(
                fontSize: 17,
                color: onSurfaceColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first entry to get started.',
              style: TextStyle(
                fontSize: 15,
                color: onSurfaceColor.withOpacity(0.3),
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.controller.filteredPasswords.length > 5
            ? 5
            : widget.controller.filteredPasswords.length,
        itemBuilder: (context, index) {
          final password = widget.controller.filteredPasswords.reversed.toList()[index];
          final isObscured = widget.controller.obscurePassword[password.id] ?? true;
          return PasswordListItemCupertino(
            key: ValueKey(password.id),
            password: password,
            isObscured: isObscured,
            dashboardController: widget.controller,
            onToggleObscure: () {
              widget.controller.toggleObscure(password.id);
              setState(() {});
            },
            primaryColor: primaryColor,
            onSurfaceColor: onSurfaceColor,
            surfaceColor: surfaceColor,
            errorColor: errorColor,
          );
        },
      ),
    );
  }
}