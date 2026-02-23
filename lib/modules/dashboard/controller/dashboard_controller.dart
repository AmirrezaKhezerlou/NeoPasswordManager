import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Padding;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:password_manager/modules/passcode/views/passcode_setup_page.dart';
import 'package:password_manager/services/storage_service/FilePermissionService.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/storage_service/storage_manager.dart';
import '../../../utils/theme_controller.dart';
import '../../../utils/translate/language_model.dart';
import '../../../utils/translate/locale_controller.dart';
import '../../passcode/controller/passcode_controller.dart';
import '../../weak_passwords/view/weak_password_page.dart';
import '../widgets/settings_bottom_Sheet.dart';
import 'package:pointycastle/export.dart' hide Padding;

class DashboardController extends GetxController {
  final RxList<PasswordModel> passwords = <PasswordModel>[].obs;
  final RxList<PasswordModel> filteredPasswords = <PasswordModel>[].obs;
  final RxList<PasswordModel> weakPasswords = <PasswordModel>[].obs;
  final RxMap<String, bool> obscurePassword = <String, bool>{}.obs;
  final RxInt savedPasswordsCount = 0.obs;
  final RxInt compromisedPasswordsCount = 0.obs;
  final TextEditingController searchController = TextEditingController();
  static const _magicHeader = 'NEOPASSv1';


  @override
  void onInit() {
    super.onInit();
    fetchAndInitializePasswords();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }



  void showThemeSelector(BuildContext context) {
    final controller = Get.find<ThemeController>();
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final onSurfaceColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E);
    final secondarySurface = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

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
                  'theme_select'.tr,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: onSurfaceColor, letterSpacing: -0.5),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: secondarySurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildThemeRow(ctx, 'light_theme'.tr, CupertinoIcons.sun_max_fill, ThemeMode.light,
                            controller.userMode.value.value, primaryColor, onSurfaceColor, controller.setThemeMode, true),
                        Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: onSurfaceColor.withOpacity(0.05)),
                        _buildThemeRow(ctx, 'dark_theme'.tr, CupertinoIcons.moon_stars_fill, ThemeMode.dark,
                            controller.userMode.value.value, primaryColor, onSurfaceColor, controller.setThemeMode, false),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('cancel'.tr, style: TextStyle(color: onSurfaceColor.withOpacity(0.5), fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeRow(BuildContext popupContext, String title, IconData icon, ThemeMode mode, ThemeMode currentMode,
      Color primaryColor, Color onSurfaceColor, Function(ThemeMode) onTap, bool isFirst) {
    final isSelected = mode == currentMode;
    return CupertinoButton(
      padding: const EdgeInsets.all(16),
      onPressed: () {
        onTap(mode);
        Navigator.pop(popupContext);
      },
      child: Row(
        children: [
          Icon(icon, color: isSelected ? primaryColor : onSurfaceColor.withOpacity(0.3), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16, color: onSurfaceColor, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400),
            ),
          ),
          if (isSelected) Icon(CupertinoIcons.checkmark_alt, color: primaryColor, size: 22, weight: 3),
        ],
      ),
    );
  }

  void showLanguageSelector(BuildContext context) {
    final localeCtrl = Get.find<LocaleController>();
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final onSurfaceColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E);
    final secondarySurface = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

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
                  'Language'.tr,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: onSurfaceColor, letterSpacing: -0.5),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: secondarySurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: List.generate(LanguageModel.languages.length, (index) {
                        final lang = LanguageModel.languages[index];
                        final isSelected = localeCtrl.currentLocale.value == lang.locale;
                        return Column(
                          children: [
                            CupertinoButton(
                              padding: const EdgeInsets.all(16),
                              onPressed: () {
                                localeCtrl.changeLocale(lang.locale);
                                Navigator.pop(ctx);
                              },
                              child: Row(
                                children: [
                                  Text(lang.flagCode, style: const TextStyle(fontSize: 22)),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      lang.name,
                                      style: TextStyle(fontSize: 16, color: onSurfaceColor, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400),
                                    ),
                                  ),
                                  if (isSelected) Icon(CupertinoIcons.checkmark_alt, color: primaryColor, size: 22, weight: 3),
                                ],
                              ),
                            ),
                            if (index != LanguageModel.languages.length - 1)
                              Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: onSurfaceColor.withOpacity(0.05)),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('cancel'.tr, style: TextStyle(color: onSurfaceColor.withOpacity(0.5), fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
  void navigateToWeakPasswords() {
    Get.to(() => const WeakPasswordsPage());
  }

  Future<void> fetchAndInitializePasswords() async {
    final allPasswords = await PasswordDatabase.instance.getAllPasswords();
    passwords.assignAll(allPasswords);
    filteredPasswords.assignAll(allPasswords);
    savedPasswordsCount.value = allPasswords.length;
    weakPasswords.clear();
    for (final p in allPasswords) {
      obscurePassword[p.id] = true;
      if (_isWeakPassword(p.password)) {
        weakPasswords.add(p);
      }
    }
    compromisedPasswordsCount.value = weakPasswords.length;
  }

  bool _isWeakPassword(String password) {
    if (password.length < 8) return true;
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    int score = 0;
    if (hasUpper) score++;
    if (hasLower) score++;
    if (hasDigit) score++;
    if (hasSpecial) score++;
    if (password.length >= 12) score++;
    return score < 3;
  }

  void filterPasswords(String query) {
    if (query.isEmpty) {
      filteredPasswords.assignAll(passwords);
    } else {
      filteredPasswords.assignAll(
        passwords
            .where((p) => (p.label?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList(),
      );
    }
  }

  void toggleObscure(String id) {
    obscurePassword[id] = !(obscurePassword[id] ?? true);
    update(['password-$id']);
  }

  Future<void> deletePassword(String id) async {
    await PasswordDatabase.instance.deletePassword(id);
    fetchAndInitializePasswords();
  }

  void copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showCupertinoDialog(
      context,
      icon: CupertinoIcons.check_mark_circled,
      title: 'copied_title'.tr,
      message: 'password_copied_message'.tr,
      primaryAction: 'ok'.tr,
    );
  }

  void showPasswordItemSettings(BuildContext context, PasswordModel model) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F9F9);
    final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final separatorColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          color: surfaceColor.withOpacity(0.94),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: separatorColor,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      model.label ?? 'no_label'.tr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? CupertinoColors.systemGrey : CupertinoColors.secondaryLabel,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: CupertinoIcons.share,
                      title: 'share'.tr,
                      onTap: () {
                        Navigator.pop(ctx);
                        _sharePassword(model);
                      },
                      color: primaryColor,
                    ),
                    Divider(height: 1, thickness: 0.5, indent: 54, color: separatorColor),
                    _buildActionTile(
                      icon: CupertinoIcons.pencil,
                      title: 'edit'.tr,
                      onTap: () {
                        Navigator.pop(ctx);
                        showEditPasswordSheet(ctx, model);
                      },
                      color: primaryColor,
                    ),
                    Divider(height: 1, thickness: 0.5, indent: 54, color: separatorColor),
                    _buildActionTile(
                      icon: CupertinoIcons.trash,
                      title: 'delete'.tr,
                      onTap: () {
                        Navigator.pop(ctx);
                        showDeleteConfirmationSheet(ctx, model);
                      },
                      color: CupertinoColors.systemRed,
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  color: isDark ? const Color(0xFF2C2C2E) : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(14),
                  onPressed: () => Navigator.pop(ctx),
                  child: Center(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
    bool isDestructive = false,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onPressed: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                color: isDestructive ? CupertinoColors.systemRed : null,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Icon(
            CupertinoIcons.chevron_right,
            size: 14,
            color: CupertinoColors.systemGrey3.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  void showEditPasswordSheet(BuildContext context, PasswordModel initial) {
    final labelCtrl = TextEditingController(text: initial.label ?? '');
    final passCtrl = TextEditingController(text: initial.password);
    bool visible = false;

    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final fieldColor = isDark ? const Color(0xFF2C2C2E) : CupertinoColors.white;
    final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final secondaryText = isDark ? CupertinoColors.systemGrey : CupertinoColors.secondaryLabel;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;

          return AnimatedPadding(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(bottom: bottomInset),
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      child: Column(
                        children: [
                          Text(
                            'edit_entry'.tr,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              color: fieldColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _buildCupertinoField(
                                  controller: labelCtrl,
                                  placeholder: 'label_optional'.tr,
                                  icon: CupertinoIcons.tag_fill,
                                  isDark: isDark,
                                  primaryColor: primaryColor,
                                ),
                                Divider(
                                    height: 1,
                                    thickness: 0.5,
                                    indent: 46,
                                    color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA)
                                ),
                                _buildCupertinoField(
                                  controller: passCtrl,
                                  placeholder: 'password'.tr,
                                  icon: CupertinoIcons.lock_fill,
                                  isDark: isDark,
                                  primaryColor: primaryColor,
                                  obscureText: !visible,
                                  suffix: CupertinoButton(
                                    padding: const EdgeInsets.only(right: 12),
                                    onPressed: () => setState(() => visible = !visible),
                                    child: Icon(
                                      visible ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
                                      color: secondaryText,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: CupertinoButton(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isDark ? const Color(0xFF2C2C2E) : CupertinoColors.white,
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text('cancel'.tr, style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CupertinoButton(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  borderRadius: BorderRadius.circular(12),
                                  color: primaryColor,
                                  onPressed: () {
                                    if (passCtrl.text.isEmpty) return;
                                    final updated = PasswordModel(
                                      id: initial.id,
                                      label: labelCtrl.text.isEmpty ? null : labelCtrl.text,
                                      password: passCtrl.text,
                                      creationDate: initial.creationDate,
                                      lastUpdated: DateTime.now(),
                                    );
                                    PasswordDatabase.instance.updatePassword(updated);
                                    fetchAndInitializePasswords();
                                    Navigator.pop(ctx);
                                    _showCupertinoDialog(
                                      context,
                                      icon: CupertinoIcons.check_mark_circled_solid,
                                      title: 'updated_title'.tr,
                                      message: 'password_updated_message'.tr,
                                      primaryAction: 'ok'.tr,
                                    );
                                  },
                                  child: Text('update'.tr, style: const TextStyle(fontWeight: FontWeight.w600, color: CupertinoColors.white)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCupertinoField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    required bool isDark,
    required Color primaryColor,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return CupertinoTextField(
      controller: controller,
      obscureText: obscureText,
      placeholder: placeholder,
      padding: const EdgeInsets.all(14),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Icon(icon, color: primaryColor.withOpacity(0.8), size: 18),
      ),
      suffix: suffix,
      placeholderStyle: TextStyle(
        color: isDark ? CupertinoColors.systemGrey : CupertinoColors.placeholderText,
        fontSize: 16,
      ),
      decoration: const BoxDecoration(color: Colors.transparent),
      style: TextStyle(
        color: isDark ? CupertinoColors.white : CupertinoColors.black,
        fontSize: 16,
      ),
    );
  }

  void showDeleteConfirmationSheet(BuildContext context, PasswordModel model) {
    final label = model.label ?? 'this_entry'.tr;
    showCupertinoDialog(
      context: context,
      builder: (ctx) {
        final isDark = CupertinoTheme.of(ctx).brightness == Brightness.dark;
        final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
        return CupertinoAlertDialog(
          title: Text('delete_password_title'.tr),
          content: Text('delete_password_message'.trParams({'label': label})),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx),
              child: Text('cancel'.tr),
            ),
            CupertinoDialogAction(
              onPressed: () {
                deletePassword(model.id);
                Navigator.pop(ctx);
                _showCupertinoDialog(
                  context,
                  icon: CupertinoIcons.check_mark_circled,
                  title: 'deleted_title'.tr,
                  message: 'password_deleted_message'.tr,
                  primaryAction: 'ok'.tr,
                );
              },
              isDestructiveAction: true,
              child: Text('delete'.tr),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sharePassword(PasswordModel model) async {
    final text = generateSecureShareText(model);
    await Share.share(text);
  }

  String generateSecureShareText(PasswordModel model) {
    final label = model.label ?? 'no_label'.tr;
    final now = DateTime.now().toIso8601String().split('.')[0];
    return '''
🔐 NeoPass Secure Share 🔐

${'label_key'.tr}: $label
${'password_key'.tr}: ${model.password}

${'shared_on'.tr}: $now

Download NeoPass to manage your credentials securely.
''';
  }

  void showSettingsSheet() {
    final context = Get.context;
    if (context != null) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) => SettingsBottomSheetCupertino(controller: this),
      );
    }
  }

  Future<void> showBackupRestoreSheet() async {
    final context = Get.context;
    if (context == null) return;

    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final onSurfaceColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E);
    final secondarySurface = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

    await showCupertinoModalPopup(
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
                  'backup_restore'.tr,
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
                      _buildBackupOption(
                        ctx,
                        CupertinoIcons.arrow_up_doc_fill,
                        'export_backup'.tr,
                        primaryColor,
                        secondarySurface,
                        onSurfaceColor,
                        exportBackup,
                      ),
                      const SizedBox(height: 12),
                      _buildBackupOption(
                        ctx,
                        CupertinoIcons.arrow_down_doc_fill,
                        'import_backup'.tr,
                        const Color(0xFF34C759),
                        secondarySurface,
                        onSurfaceColor,
                        importBackup,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'cancel'.tr,
                            style: TextStyle(
                              color: onSurfaceColor.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackupOption(
      BuildContext context,
      IconData icon,
      String title,
      Color color,
      Color bgColor,
      Color textColor,
      VoidCallback onTap,
      ) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Transform.flip(
              flipX: isRtl,
              child: Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: textColor.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> importFromCSV() async {
    if (kIsWeb) return;
    try {
      await FilePermissionService.requestStoragePermission();
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        dialogTitle: 'select_csv_file'.tr,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final entries = _parseCSV(content);

        if (entries.isEmpty) {
          _showCupertinoDialog(
            Get.context!,
            icon: CupertinoIcons.exclamationmark_circle,
            title: 'no_entries_found'.tr,
            message: 'csv_empty_invalid'.tr,
            primaryAction: 'ok'.tr,
          );
          return;
        }

        for (final entry in entries) {
          final model = PasswordModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + math.Random().nextInt(10000).toString(),
            label: entry['label'],
            password: entry['password']!,
            creationDate: DateTime.now(),
            lastUpdated: DateTime.now(),
          );
          await PasswordDatabase.instance.addPassword(model);
        }
        fetchAndInitializePasswords();

        _showCupertinoDialog(
          Get.context!,
          icon: CupertinoIcons.check_mark_circled,
          title: 'import_complete'.tr,
          message: 'imported_count_message'.trParams({'count': entries.length.toString()}),
          primaryAction: 'ok'.tr,
        );
      }
    } catch (e) {
      _showCupertinoDialog(
        Get.context!,
        icon: CupertinoIcons.exclamationmark_circle,
        title: 'import_failed'.tr,
        message: 'invalid_csv_format'.tr,
        primaryAction: 'ok'.tr,
      );
    }
  }

  List<Map<String, String?>> _parseCSV(String content) {
    final lines = content.split('\n');
    if (lines.isEmpty || lines[0].trim().isEmpty) return [];

    final entries = <Map<String, String?>>[];
    final headers = _splitCSVLine(lines[0]);

    int labelIndex = -1, passwordIndex = -1;
    for (int i = 0; i < headers.length; i++) {
      final header = headers[i].toLowerCase().trim();
      if (header == 'label' || header == 'title' || header == 'name') labelIndex = i;
      if (header == 'password' || header == 'pass') passwordIndex = i;
    }

    if (passwordIndex == -1) return [];

    for (int i = 1; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue;
      final fields = _splitCSVLine(lines[i]);
      if (fields.length <= passwordIndex) continue;

      entries.add({
        'label': labelIndex != -1 && fields.length > labelIndex ? fields[labelIndex].trim() : null,
        'password': fields[passwordIndex].trim(),
      });
    }
    return entries;
  }

  List<String> _splitCSVLine(String line) {
    final fields = <String>[];
    final chars = line.split('');
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < chars.length; i++) {
      final c = chars[i];
      if (c == '"') {
        if (i + 1 < chars.length && chars[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (c == ',' && !inQuotes) {
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(c);
      }
    }
    fields.add(buffer.toString());
    return fields;
  }

  void _showCupertinoDialog(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String message,
        required String primaryAction,
      }) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    var iconColor = isDark ? const Color(0xFF30D158) : const Color(0xFF00C741);
    final textColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E);

    if (icon == CupertinoIcons.exclamationmark_circle) {
      iconColor = isDark ? const Color(0xFFFF453A) : const Color(0xFFFF3B30);
    }

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 8),
            Text(title.tr, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(message.tr, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 15)),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text(primaryAction.tr, style: TextStyle(color: iconColor, fontSize: 17)),
          ),
        ],
      ),
    );
  }

  Future<encrypt.Key> _deriveKeyFromPassword(String password, Uint8List salt) async {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, 100000, 32));
    final keyBytes = pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
    return encrypt.Key(keyBytes);
  }

  Uint8List _randomBytes(int length) {
    final random = math.Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
  }

  Future<String> _encryptData(String plaintext, String password) async {
    final salt = _randomBytes(16);
    final iv = encrypt.IV(_randomBytes(16));
    final key = await _deriveKeyFromPassword(password, salt);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return '${base64Encode(salt)}:${base64Encode(iv.bytes)}:${encrypted.base64}';
  }

  Future<String> _decryptData(String encryptedData, String password) async {
    final parts = encryptedData.split(':');
    if (parts.length != 3) throw Exception('Invalid encrypted format');
    final salt = base64Decode(parts[0]);
    final iv = encrypt.IV.fromBase64(parts[1]);
    final key = await _deriveKeyFromPassword(password, Uint8List.fromList(salt));
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    return encrypter.decrypt64(parts[2], iv: iv);
  }

  Future<String?> _askBackupPassword({bool confirm = false}) async {
    final context = Get.context;
    if (context == null) return null;

    final ctrl1 = TextEditingController();
    final ctrl2 = TextEditingController();

    return await showCupertinoDialog<String?>(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: Text(confirm ? 'set_backup_password'.tr : 'enter_backup_password'.tr),
          content: Container(
            height: confirm ? 120 : 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoTextField(
                  controller: ctrl1,
                  obscureText: true,
                  placeholder: 'password_key'.tr,
                ),
                if (confirm) ...[
                  const SizedBox(height: 12),
                  CupertinoTextField(
                    controller: ctrl2,
                    obscureText: true,
                    placeholder: 'confirm_password'.tr,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx, null),
              child: Text('cancel'.tr),
            ),
            CupertinoDialogAction(
              onPressed: () {
                if (ctrl1.text.isEmpty) return;
                if (confirm && ctrl1.text != ctrl2.text) return;
                Navigator.pop(ctx, ctrl1.text);
              },
              child: Text('ok'.tr),
            ),
          ],
        );
      },
    );
  }

  Future<void> exportBackup() async {
    if (kIsWeb) return;
    try {
      final password = await _askBackupPassword(confirm: true);
      if (password == null) return;

      await FilePermissionService.requestStoragePermission();

      final jsonList = passwords.map((p) => p.toMap()).toList();
      final jsonString = jsonEncode(jsonList);
      final encrypted = await _encryptData(jsonString, password);

      final bytes = Uint8List.fromList(utf8.encode('$_magicHeader$encrypted'));
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'save_backup'.tr,
        fileName: 'neopass_backup_${DateTime.now().millisecondsSinceEpoch}.neopass',
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: ['neopass'],
      );

      if (result != null) {
        _showCupertinoDialog(
          Get.context!,
          icon: CupertinoIcons.check_mark_circled,
          title: 'backup_saved'.tr,
          message: 'backup_saved_message'.tr,
          primaryAction: 'ok'.tr,
        );
      }
    } catch (e) {
      _showCupertinoDialog(
        Get.context!,
        icon: CupertinoIcons.exclamationmark_circle,
        title: 'export_failed'.tr,
        message: 'unable_save_backup'.tr,
        primaryAction: 'ok'.tr,
      );
    }
  }

  Future<void> importBackup() async {
    if (kIsWeb) return;
    try {
      await FilePermissionService.requestStoragePermission();
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['neopass'],
        dialogTitle: 'select_backup_file'.tr,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        if (!content.startsWith(_magicHeader)) {
          _showCupertinoDialog(
            Get.context!,
            icon: CupertinoIcons.exclamationmark_circle,
            title: 'invalid_file'.tr,
            message: 'not_valid_neopass_backup'.tr,
            primaryAction: 'ok'.tr,
          );
          return;
        }

        final password = await _askBackupPassword(confirm: false);
        if (password == null) return;

        final encryptedData = content.substring(_magicHeader.length);
        final decrypted = await _decryptData(encryptedData, password);
        final list = jsonDecode(decrypted) as List;
        final models = list.map((e) => PasswordModel.fromMap(e as Map<String, dynamic>)).toList();

        for (final m in models) {
          await PasswordDatabase.instance.addPassword(m);
        }
        fetchAndInitializePasswords();

        _showCupertinoDialog(
          Get.context!,
          icon: CupertinoIcons.check_mark_circled,
          title: 'restore_complete'.tr,
          message: 'imported_entries_message'.trParams({'count': models.length.toString()}),
          primaryAction: 'ok'.tr,
        );
      }
    } catch (e) {
      _showCupertinoDialog(
        Get.context!,
        icon: CupertinoIcons.exclamationmark_circle,
        title: 'import_failed'.tr,
        message: 'wrong_password_invalid_backup'.tr,
        primaryAction: 'ok'.tr,
      );
    }
  }

}