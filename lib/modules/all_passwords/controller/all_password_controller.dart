import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../services/storage_service/storage_manager.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
class AllPasswordsController extends GetxController {
  final DashboardController dashboardController;
  final RxList<PasswordModel> selectedPasswords = <PasswordModel>[].obs;
  final RxBool isSelectionMode = false.obs;
  final TextEditingController searchController = TextEditingController();

  AllPasswordsController(this.dashboardController);

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedPasswords.clear();
    }
  }

  void exitSelectionMode() {
    isSelectionMode.value = false;
    selectedPasswords.clear();
  }

  void toggleSelectPassword(PasswordModel password) {
    if (selectedPasswords.contains(password)) {
      selectedPasswords.remove(password);
    } else {
      selectedPasswords.add(password);
    }
  }

  void selectAll() {
    selectedPasswords.assignAll(dashboardController.passwords);
  }

  void deselectAll() {
    selectedPasswords.clear();
  }

  Future<void> deleteSelectedPasswords() async {
    for (final password in selectedPasswords) {
      await dashboardController.deletePassword(password.id);
    }
    selectedPasswords.clear();
    isSelectionMode.value = false;
  }

  void filterPasswords(String query) {
    dashboardController.filterPasswords(query);
  }

  void showDeleteConfirmation() {
    final context = Get.context;
    if (context == null || !context.mounted) return;

    showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: Text('delete_selected_title'.tr),
          content: Text('delete_selected_message'.trParams({'count': selectedPasswords.length.toString()})),
          actions: [
            CupertinoDialogAction(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr)),
            CupertinoDialogAction(
              onPressed: () {
                deleteSelectedPasswords();
                Navigator.pop(ctx);
              },
              isDestructiveAction: true,
              child: Text('delete'.tr),
            ),
          ],
        );
      },
    );
  }



  void showPasswordItemSettings(BuildContext context, PasswordModel model) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final dividerColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5E5);

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  model.label ?? 'no_label'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.secondaryLabel.resolveFrom(ctx),
                    letterSpacing: -0.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        _buildActionTile(ctx, CupertinoIcons.doc_on_doc, 'copy'.tr, () {
                          Navigator.pop(ctx);
                          dashboardController.copyToClipboard(ctx, model.password);
                        }, primaryColor, dividerColor, true),
                        _buildActionTile(ctx, CupertinoIcons.share, 'share'.tr, () {
                          Navigator.pop(ctx);
                          _sharePassword(model);
                        }, primaryColor, dividerColor, true),
                        _buildActionTile(ctx, CupertinoIcons.pencil, 'edit'.tr, () {
                          Navigator.pop(ctx);
                          dashboardController.showEditPasswordSheet(ctx, model);
                        }, primaryColor, dividerColor, true),
                        _buildActionTile(ctx, CupertinoIcons.trash, 'delete'.tr, () {
                          Navigator.pop(ctx);
                          dashboardController.showDeleteConfirmationSheet(ctx, model);
                        }, const Color(0xFFFF453A), dividerColor, false),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(ctx),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'cancel'.tr,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      Color iconColor,
      Color dividerColor,
      bool showDivider,
      ) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      color: CupertinoColors.label.resolveFrom(context),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: isRtl ? math.pi : 0,
                  child: Icon(
                    CupertinoIcons.chevron_forward,
                    size: 14,
                    color: CupertinoColors.systemGrey2.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: EdgeInsets.only(
                left: isRtl ? 0 : 52,
                right: isRtl ? 52 : 0,
              ),
              child: Container(
                height: 0.5,
                color: dividerColor,
              ),
            ),
        ],
      ),
    );
  }
  Future<void> _sharePassword(PasswordModel model) async {
    final text = dashboardController.generateSecureShareText(model);
    Share.share(text);
  }
}