import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../services/storage_service/storage_manager.dart';
import '../../dashboard/controller/dashboard_controller.dart';

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
          title: const Text('Delete Selected?'),
          content: Text('Delete ${selectedPasswords.length} passwords?'),
          actions: [
            CupertinoDialogAction(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            CupertinoDialogAction(
              onPressed: () {
                deleteSelectedPasswords();
                Navigator.pop(ctx);
              },
              isDestructiveAction: true,
              child: const Text('Delete'),
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

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: SafeArea(
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      model.label ?? 'No Label',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildActionTile(ctx, CupertinoIcons.doc_on_doc, 'Copy', () {
                          Navigator.pop(ctx);
                          dashboardController.copyToClipboard(ctx, model.password);
                        }, primaryColor),
                        _buildActionTile(ctx, CupertinoIcons.share, 'Share', () {
                          Navigator.pop(ctx);
                          _sharePassword(model);
                        }, primaryColor),
                        _buildActionTile(ctx, CupertinoIcons.pencil, 'Edit', () {
                          Navigator.pop(ctx);
                          dashboardController.showEditPasswordSheet(ctx, model);
                        }, primaryColor),
                        _buildActionTile(ctx, CupertinoIcons.trash, 'Delete', () {
                          Navigator.pop(ctx);
                          dashboardController.showDeleteConfirmationSheet(ctx, model);
                        }, const Color(0xFFFF3B30)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel', style: TextStyle(color: primaryColor)),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title, VoidCallback onTap, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        alignment: Alignment.centerLeft,
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 17)),
          ],
        ),
      ),
    );
  }

  Future<void> _sharePassword(PasswordModel model) async {
    final text = dashboardController.generateSecureShareText(model);
    Share.share(text);
  }
}