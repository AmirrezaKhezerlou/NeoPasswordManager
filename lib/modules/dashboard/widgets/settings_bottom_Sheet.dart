import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../passcode/controller/passcode_controller.dart';
import '../../passcode/views/passcode_setup_page.dart';
import '../controller/dashboard_controller.dart';

class SettingsBottomSheetCupertino extends StatelessWidget {
  final DashboardController controller;

  const SettingsBottomSheetCupertino({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFFFFFFF);
    final primaryColor = isDark
        ? const Color(0xFF0A84FF)
        : const Color(0xFF007AFF);
    final onSurfaceColor = isDark
        ? const Color(0xFFE5E5EA)
        : const Color(0xFF1C1C1E);
    final passcodeCtrl = Get.find<PasscodeController>();

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
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF3A3A3C)
                          : const Color(0xFFC7C7CC),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'NeoPass Settings',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: onSurfaceColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildCupertinoSettingOption(
                      context,
                      CupertinoIcons.arrow_up_arrow_down,
                      'Import / Export',
                      () => controller.showBackupRestoreSheet(),
                      primaryColor,
                    ),
                    _buildCupertinoSettingOption(
                      context,
                      CupertinoIcons.arrow_down_left_square,
                      'Source Code',
                      () async {
                        await launchUrl(
                          Uri.parse(
                            'https://github.com/AmirrezaKhezerlou/NeoPasswordManager',
                          ),
                        );
                      },
                      primaryColor,
                    ),
                    if (Platform.isAndroid)
                      _buildCupertinoSettingOption(
                        context,
                        CupertinoIcons.checkmark_seal,
                        'Check For Update',
                        () => openBazaarDetails(),
                        primaryColor,
                      ),
                    if (Platform.isAndroid)
                      _buildCupertinoSettingOption(
                        context,
                        CupertinoIcons.cloud_download,
                        'Download For Windows',
                        () => openBazaarDetails(),
                        primaryColor,
                      ),
                    if (Platform.isWindows)
                      _buildCupertinoSettingOption(
                        context,
                        CupertinoIcons.cloud_download,
                        'Download Android',
                        () => openBazaarDetails(),
                        primaryColor,
                      ),
                    if (passcodeCtrl.hasPasscode)
                      _buildCupertinoSettingOption(
                        context,
                        CupertinoIcons.trash,
                        'Remove Passcode',
                        () => _confirmRemovePasscode(context, passcodeCtrl),
                        const Color(0xFFFF3B30),
                      )
                    else
                      _buildCupertinoSettingOption(
                        context,
                        CupertinoIcons.lock,
                        'Set App Passcode',
                        () => Get.to(() => const PasscodeSetupPage()),
                        primaryColor,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  void openBazaarDetails() {
    if (!Platform.isAndroid) return;

    const packageName = 'com.neo.passwordmanager';

    final intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      data: 'bazaar://details?id=$packageName',
      package: 'com.farsitel.bazaar',
    );

    intent.launch();
  }

  Widget _buildCupertinoSettingOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
        alignment: Alignment.centerLeft,
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 21),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _confirmRemovePasscode(
    BuildContext context,
    PasscodeController passcodeCtrl,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) {
        final isDark = CupertinoTheme.of(ctx).brightness == Brightness.dark;
        final primaryColor = isDark
            ? const Color(0xFF0A84FF)
            : const Color(0xFF007AFF);
        return CupertinoAlertDialog(
          title: const Text('Remove Passcode?'),
          content: const Text(
            'This will disable app lock protection. Your passwords will still be stored securely.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                await passcodeCtrl.storage.delete(key: 'app_passcode');
                passcodeCtrl.storedPasscode.value = '';
                Navigator.pop(ctx); // بستن دیالوگ تأیید
                Navigator.pop(context); // بستن باتم‌شیت تنظیمات

                // نمایش دیالوگ موفقیت با استفاده از Get.context که همیشه در دسترسه
                if (Get.context != null) {
                  showCupertinoDialog(
                    context: Get.context!,
                    builder: (ctx) => CupertinoAlertDialog(
                      title: const Text('Passcode Removed'),
                      content: const Text(
                        'App lock protection has been disabled.',
                      ),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              isDestructiveAction: true,
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
