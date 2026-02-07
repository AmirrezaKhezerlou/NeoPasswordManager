// weak_passwords_controller.dart
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text('Update Weak Password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 20),
                            CupertinoTextField(
                              controller: labelCtrl,
                              placeholder: 'Label (Optional)',
                              prefix: Icon(CupertinoIcons.tag, color: primaryColor),
                              placeholderStyle: TextStyle(color: onSurfaceColor.withOpacity(0.5)),
                              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12)),
                              style: TextStyle(color: onSurfaceColor),
                            ),
                            const SizedBox(height: 16),
                            CupertinoTextField(
                              controller: passCtrl,
                              obscureText: !visible,
                              placeholder: 'New Password',
                              prefix: Icon(CupertinoIcons.lock, color: primaryColor),
                              suffix: CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => setState(() => visible = !visible),
                                child: Icon(
                                  visible ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                                  color: primaryColor,
                                ),
                              ),
                              placeholderStyle: TextStyle(color: onSurfaceColor.withOpacity(0.5)),
                              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12)),
                              style: TextStyle(color: onSurfaceColor),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: warningColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(CupertinoIcons.info, color: warningColor, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Use a strong password with uppercase, lowercase, numbers and symbols',
                                      style: TextStyle(fontSize: 12, color: warningColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,

                              child: CupertinoButton.filled(
                                onPressed: save,
                                child: const Text('Update Password'),
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