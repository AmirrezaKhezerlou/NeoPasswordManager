import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        AdvancedPasswordSheet(initialPassword: handler.take()).show(context);
      }
    });

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CustomDashboardAppbarCupertino(
        onSettingsTap: controller.showSettingsSheet,
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstVariables.mainPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Obx(() => Row(
                      children: [
                        Expanded(
                          child: InfoSquareWidgetCupertino(
                            count: controller.savedPasswordsCount.value,
                            title: 'passwords_stored'.tr,
                            color: primaryColor,
                            surfaceColor: surfaceColor,
                            onSurfaceColor: onSurfaceColor,
                            icon: CupertinoIcons.lock_shield_fill,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InfoSquareWidgetCupertino(
                            count: controller.compromisedPasswordsCount.value,
                            title: 'weak_passwords'.tr,
                            color: errorColor,
                            surfaceColor: surfaceColor,
                            onSurfaceColor: onSurfaceColor,
                            icon: CupertinoIcons.exclamationmark_shield_fill,
                            onTap: controller.compromisedPasswordsCount.value > 0
                                ? controller.navigateToWeakPasswords
                                : null,
                          ),
                        ),
                      ],
                    )),
                    const SizedBox(height: 24),
                    CupertinoSearchTextField(
                      controller: controller.searchController,
                      onChanged: controller.filterPasswords,
                      placeholder: 'search_label'.tr,
                      backgroundColor: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(height: 20),
                    Hero(
                      tag: 'add_password_hero',
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: CupertinoButton.filled(
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(14),
                          onPressed: () => AdvancedPasswordSheet().show(context),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(CupertinoIcons.plus_circle_fill, size: 20, color: CupertinoColors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'add_new_password'.tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'recent_passwords'.tr,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: onSurfaceColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Get.to(() => const AllPasswordsPage()),
                          child: Row(
                            children: [
                              Text(
                                'see_all'.tr,
                                style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 4),
                              const _DirectionalChevron(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: AppConstVariables.mainPadding, vertical: 8),
            sliver: PasswordListViewWidgetCupertino(controller: controller),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
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
  final IconData icon;
  final VoidCallback? onTap;

  const InfoSquareWidgetCupertino({
    super.key,
    required this.count,
    required this.title,
    required this.color,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (onTap != null)
                  const _DirectionalChevron(size: 14, color: CupertinoColors.systemGrey3),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: onSurfaceColor,
                letterSpacing: -1,
              ),
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: onSurfaceColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordListViewWidgetCupertino extends StatelessWidget {
  final DashboardController controller;

  const PasswordListViewWidgetCupertino({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final onSurfaceColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E);
    final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final errorColor = isDark ? const Color(0xFFFF453A) : const Color(0xFFFF3B30);

    return Obx(() {
      final list = controller.filteredPasswords.reversed.toList();
      final displayList = list.length > 5 ? list.sublist(0, 5) : list;

      if (displayList.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.lock_open, size: 64, color: onSurfaceColor.withOpacity(0.1)),
                const SizedBox(height: 16),
                Text(
                  'no_passwords_found'.tr,
                  style: TextStyle(fontSize: 17, color: onSurfaceColor.withOpacity(0.4), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final password = displayList[index];
            return Obx(() {
              final isObscured = controller.obscurePassword[password.id] ?? true;
              return PasswordListItemCupertino(
                key: ValueKey(password.id),
                password: password,
                isObscured: isObscured,
                dashboardController: controller,
                onToggleObscure: () => controller.toggleObscure(password.id),
                primaryColor: primaryColor,
                onSurfaceColor: onSurfaceColor,
                surfaceColor: surfaceColor,
                errorColor: errorColor,
              );
            });
          },
          childCount: displayList.length,
        ),
      );
    });
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => dashboardController.showPasswordItemSettings(context, password),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isWeak ? errorColor.withOpacity(0.3) : onSurfaceColor.withOpacity(0.04),
              width: 1,
            ),
          ),
          child: Row(
            children: [
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: onSurfaceColor),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionBtn(
                    icon: isObscured ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill,
                    onTap: onToggleObscure,
                  ),
                  _buildActionBtn(
                    icon: CupertinoIcons.doc_on_doc_fill,
                    onTap: () => dashboardController.copyToClipboard(context, password.password),
                  ),
                  const SizedBox(width: 12),
                  const _DirectionalChevron(size: 14, color: CupertinoColors.systemGrey3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn({required IconData icon, required VoidCallback onTap}) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      minSize: 36,
      onPressed: onTap,
      child: Icon(icon, color: onSurfaceColor.withOpacity(0.3), size: 20),
    );
  }
}

class _DirectionalChevron extends StatelessWidget {
  final double size;
  final Color? color;

  const _DirectionalChevron({this.size = 16, this.color});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Transform.rotate(
      angle: isRtl ? math.pi : 0,
      child: Icon(
        CupertinoIcons.chevron_forward,
        size: size,
        color: color ?? CupertinoTheme.of(context).primaryColor,
      ),
    );
  }
}