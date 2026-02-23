import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../services/storage_service/storage_manager.dart';
import '../../dashboard/controller/dashboard_controller.dart';

class WeakPasswordsController extends GetxController {
  final DashboardController dashboardController;

  WeakPasswordsController(this.dashboardController);

  List<PasswordModel> get weakPasswords => dashboardController.weakPasswords;

  Future<void> updatePassword(PasswordModel oldModel, String newLabel, String newPassword) async {
    final updated = PasswordModel(
      id: oldModel.id,
      label: newLabel.isEmpty ? null : newLabel,
      password: newPassword,
      creationDate: oldModel.creationDate,
      lastUpdated: DateTime.now(),
    );
    await PasswordDatabase.instance.updatePassword(updated);
    await dashboardController.fetchAndInitializePasswords();
  }

  void showEditSheet(BuildContext context, PasswordModel password) {
    final labelCtrl = TextEditingController(text: password.label ?? '');
    final passCtrl = TextEditingController(text: password.password);
    bool visible = false;

    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final inputColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
    final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final onSurfaceColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E);
    final warningColor = const Color(0xFFFF9500);

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        void save() {
          if (passCtrl.text.isEmpty) return;
          updatePassword(password, labelCtrl.text, passCtrl.text);
          Navigator.of(ctx).pop();
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFC7C7CC),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'update_weak_password'.tr,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: onSurfaceColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            CupertinoTextField(
                              controller: labelCtrl,
                              padding: const EdgeInsets.all(16),
                              placeholder: 'label_optional'.tr,
                              prefix: Padding(
                                padding: const EdgeInsetsDirectional.only(start: 12),
                                child: Icon(CupertinoIcons.tag_fill, color: primaryColor, size: 20),
                              ),
                              placeholderStyle: TextStyle(color: onSurfaceColor.withOpacity(0.3)),
                              decoration: BoxDecoration(color: inputColor, borderRadius: BorderRadius.circular(14)),
                              style: TextStyle(color: onSurfaceColor),
                            ),
                            const SizedBox(height: 16),
                            CupertinoTextField(
                              controller: passCtrl,
                              padding: const EdgeInsets.all(16),
                              obscureText: !visible,
                              placeholder: 'new_password'.tr,
                              prefix: Padding(
                                padding: const EdgeInsetsDirectional.only(start: 12),
                                child: Icon(CupertinoIcons.lock_fill, color: primaryColor, size: 20),
                              ),
                              suffix: CupertinoButton(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                onPressed: () => setState(() => visible = !visible),
                                child: Icon(
                                  visible ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill,
                                  color: onSurfaceColor.withOpacity(0.3),
                                  size: 20,
                                ),
                              ),
                              placeholderStyle: TextStyle(color: onSurfaceColor.withOpacity(0.3)),
                              decoration: BoxDecoration(color: inputColor, borderRadius: BorderRadius.circular(14)),
                              style: TextStyle(color: onSurfaceColor, fontFamily: visible ? 'Courier' : null),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: warningColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: warningColor.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Icon(CupertinoIcons.lightbulb_fill, color: warningColor, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'strong_password_tip'.tr,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: warningColor,
                                        fontWeight: FontWeight.w500,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: CupertinoButton.filled(
                                borderRadius: BorderRadius.circular(16),
                                onPressed: save,
                                child: Text(
                                  'update_password'.tr,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                'cancel'.tr,
                                style: TextStyle(color: onSurfaceColor.withOpacity(0.5), fontWeight: FontWeight.w500),
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
            );
          },
        );
      },
    );
  }
}