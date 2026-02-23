import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    final backgroundColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : CupertinoColors.white;
    final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final dividerColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);
    final passcodeCtrl = Get.find<PasscodeController>();

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
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
            const SizedBox(height: 16),
            Text(
              'settings_title'.tr,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  children: [
                    _buildSettingsGroup(
                      cardColor,
                      dividerColor,
                      [
                        _buildOption(context, CupertinoIcons.globe, 'Language'.tr, primaryColor, () => controller.showLanguageSelector(context)),
                        _buildOption(context, CupertinoIcons.cloud_sun_fill, 'theme_select'.tr, primaryColor, () {
                          Get.back();
                          controller.showThemeSelector(context);
                        }),
                        _buildOption(context, CupertinoIcons.arrow_up_arrow_down, 'import_export'.tr, primaryColor, () => controller.showBackupRestoreSheet()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSettingsGroup(
                      cardColor,
                      dividerColor,
                      [
                        _buildOption(context, CupertinoIcons.doc_text_fill, 'source_code'.tr, primaryColor, () async {
                          await launchUrl(Uri.parse('https://github.com/AmirrezaKhezerlou/NeoPasswordManager'));
                        }),
                        if (Platform.isAndroid)
                          _buildOption(context, CupertinoIcons.checkmark_seal_fill, 'check_update'.tr, primaryColor, () => openBazaarDetails()),
                        if (Platform.isAndroid)
                          _buildOption(context, CupertinoIcons.cloud_download_fill, 'download_windows'.tr, primaryColor, () async {
                            await launchUrl(Uri.parse('https://github.com/AmirrezaKhezerlou/NeoPasswordManager/releases'));
                          }),
                        if (Platform.isWindows)
                          _buildOption(context, CupertinoIcons.cloud_download_fill, 'download_android'.tr, primaryColor, () async {
                            await launchUrl(Uri.parse('https://cafebazaar.ir/app/com.neo.passwordmanager'));
                          }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSettingsGroup(
                      cardColor,
                      dividerColor,
                      [
                        if (passcodeCtrl.hasPasscode)
                          _buildOption(
                            context,
                            CupertinoIcons.lock_slash_fill,
                            'remove_passcode'.tr,
                            CupertinoColors.systemRed,
                                () => _confirmRemovePasscode(context, passcodeCtrl),
                            isDestructive: true,
                          )
                        else
                          _buildOption(
                            context,
                            CupertinoIcons.lock_shield_fill,
                            'set_app_passcode'.tr,
                            primaryColor,
                                () => Get.to(() => const PasscodeSetupPage()),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(Color color, Color dividerColor, List<Widget> children) {
    List<Widget> items = [];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(Divider(height: 1, thickness: 0.5, indent: 54, color: dividerColor));
      }
    }
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Column(children: items),
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap, {bool isDestructive = false}) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onPressed: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16, color: isDestructive ? CupertinoColors.systemRed : null, fontWeight: FontWeight.w400),
            ),
          ),
          Transform.flip(
            flipX: isRtl,
            child: Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: CupertinoColors.systemGrey3.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  void openBazaarDetails() {
    if (!Platform.isAndroid) return;
    const intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      data: 'bazaar://details?id=com.neo.passwordmanager',
      package: 'com.farsitel.bazaar',
    );
    intent.launch();
  }

  void _confirmRemovePasscode(BuildContext context, PasscodeController passcodeCtrl) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('remove_passcode_title'.tr),
        content: Text('remove_passcode_message'.tr),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              await passcodeCtrl.storage.delete(key: 'app_passcode');
              passcodeCtrl.storedPasscode.value = '';
              Navigator.pop(ctx);
              Navigator.pop(context);
              _showSimpleAlert(Get.context!, 'passcode_removed_title'.tr, 'passcode_removed_message'.tr);
            },
            child: Text('remove'.tr),
          ),
        ],
      ),
    );
  }

  void _showSimpleAlert(BuildContext context, String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [CupertinoDialogAction(onPressed: () => Navigator.pop(ctx), child: Text('ok'.tr))],
      ),
    );
  }
}