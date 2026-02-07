// dashboard_controller.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:password_manager/modules/passcode/views/passcode_setup_page.dart';
import 'package:password_manager/services/storage_service/FilePermissionService.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/storage_service/storage_manager.dart';
import '../../passcode/controller/passcode_controller.dart';
import '../../weak_passwords/view/weak_password_page.dart';
import '../widgets/settings_bottom_Sheet.dart';

class DashboardController extends GetxController {
  final RxList<PasswordModel> passwords = <PasswordModel>[].obs;
  final RxList<PasswordModel> filteredPasswords = <PasswordModel>[].obs;
  final RxList<PasswordModel> weakPasswords = <PasswordModel>[].obs;
  final RxMap<String, bool> obscurePassword = <String, bool>{}.obs;
  final RxInt savedPasswordsCount = 0.obs;
  final RxInt compromisedPasswordsCount = 0.obs;
  final TextEditingController searchController = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();
  static const _magicHeader = 'NEOPASSv1';
  static const _keyName = 'backup_encryption_key';

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
      title: 'Copied!',
      message: 'Password copied to clipboard',
      primaryAction: 'OK',
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
                    padding: const EdgeInsets.only(top: 10, bottom: 6),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFC7C7CC),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      model.label ?? 'No Label',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildCupertinoActionTile(ctx, CupertinoIcons.share, 'Share', () {
                          Navigator.pop(ctx);
                          _sharePassword(model);
                        }, primaryColor),
                        _buildCupertinoActionTile(ctx, CupertinoIcons.pencil, 'Edit', () {
                          Navigator.pop(ctx);
                          showEditPasswordSheet(ctx, model);
                        }, primaryColor),
                        _buildCupertinoActionTile(ctx, CupertinoIcons.trash, 'Delete', () {
                          Navigator.pop(ctx);
                          showDeleteConfirmationSheet(ctx, model);
                        }, const Color(0xFFFF3B30)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel', style: TextStyle(color: primaryColor, fontSize: 17)),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCupertinoActionTile(
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

  void showEditPasswordSheet(BuildContext context, PasswordModel initial) {
    final labelCtrl = TextEditingController(text: initial.label ?? '');
    final passCtrl = TextEditingController(text: initial.password);
    bool visible = false;

    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final onSurfaceColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E);

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        void save() {
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
          Navigator.of(ctx).pop();
          _showCupertinoDialog(
            context,
            icon: CupertinoIcons.check_mark_circled,
            title: 'Updated!',
            message: 'Password entry updated successfully',
            primaryAction: 'OK',
          );
        }

        return StatefulBuilder(
          builder: (context, setState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return AnimatedPadding(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: SafeArea(
                  top: false,
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
                                color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFC7C7CC),
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Text(
                                  'Edit Entry',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 18),
                              CupertinoTextField(
                                controller: labelCtrl,
                                placeholder: 'Label (Optional)',
                                prefix: Icon(CupertinoIcons.tag, color: primaryColor, size: 20),
                                placeholderStyle: TextStyle(color: onSurfaceColor.withOpacity(0.5)),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                style: TextStyle(color: onSurfaceColor),
                              ),
                              const SizedBox(height: 14),
                              CupertinoTextField(
                                controller: passCtrl,
                                obscureText: !visible,
                                placeholder: 'Password',
                                prefix: Icon(CupertinoIcons.lock, color: primaryColor, size: 20),
                                suffix: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => setState(() => visible = !visible),
                                  child: Icon(
                                    visible ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                ),
                                placeholderStyle: TextStyle(color: onSurfaceColor.withOpacity(0.5)),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                style: TextStyle(color: onSurfaceColor),
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                child: CupertinoButton.filled(
                                  onPressed: save,
                                  child: const Text('Update', style: TextStyle(fontSize: 17)),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  void showDeleteConfirmationSheet(BuildContext context, PasswordModel model) {
    final label = model.label ?? 'this entry';
    showCupertinoDialog(
      context: context,
      builder: (ctx) {
        final isDark = CupertinoTheme.of(ctx).brightness == Brightness.dark;
        final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
        return CupertinoAlertDialog(
          title: const Text('Delete Password?'),
          content: Text('Permanently delete "$label"? This action cannot be undone.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                deletePassword(model.id);
                Navigator.pop(ctx);
                _showCupertinoDialog(
                  context,
                  icon: CupertinoIcons.check_mark_circled,
                  title: 'Deleted!',
                  message: 'Password entry deleted successfully',
                  primaryAction: 'OK',
                );
              },
              isDestructiveAction: true,
              child: const Text('Delete'),
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
    final label = model.label ?? 'No Label';
    final now = DateTime.now().toIso8601String().split('.')[0];
    return '''
🔐 NeoPass Secure Share 🔐

Label: $label
Password: ${model.password}

Shared on: $now

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

    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: SafeArea(
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
                        color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFC7C7CC),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    children: [
                      Text(
                        'Backup & Restore',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: onSurfaceColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _buildBackupOption(ctx, CupertinoIcons.arrow_down_to_line, 'Export Backup', primaryColor, exportBackup),
                      _buildBackupOption(ctx, CupertinoIcons.arrow_up_to_line, 'Import Backup', primaryColor, importBackup),

                      const SizedBox(height: 10),
                      CupertinoButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancel', style: TextStyle(color: primaryColor, fontSize: 17)),
                      ),
                      const SizedBox(height: 10),
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

  Widget _buildBackupOption(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        alignment: Alignment.centerLeft,
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Future<void> exportBackup() async {
    if (kIsWeb) return;
    try {
      await FilePermissionService.requestStoragePermission();

      final jsonList = passwords.map((p) => p.toMap()).toList();
      final jsonString = jsonEncode(jsonList);
      final encrypted = await _encryptData(jsonString);

      final bytes = Uint8List.fromList(utf8.encode('$_magicHeader$encrypted'));
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup',
        fileName: 'neopass_backup_${DateTime.now().millisecondsSinceEpoch}.neopass',
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: ['neopass'],
      );

      if (result != null) {
        _showCupertinoDialog(
          Get.context!,
          icon: CupertinoIcons.check_mark_circled,
          title: 'Backup Saved!',
          message: 'Encrypted backup saved successfully',
          primaryAction: 'OK',
        );
      }
    } catch (e) {
      _showCupertinoDialog(
        Get.context!,
        icon: CupertinoIcons.exclamationmark_circle,
        title: 'Export Failed',
        message: 'Unable to save backup file',
        primaryAction: 'OK',
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
        dialogTitle: 'Select Backup File',
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        if (!content.startsWith(_magicHeader)) {
          _showCupertinoDialog(
            Get.context!,
            icon: CupertinoIcons.exclamationmark_circle,
            title: 'Invalid File',
            message: 'This is not a valid NeoPass backup file',
            primaryAction: 'OK',
          );
          return;
        }

        final encryptedData = content.substring(_magicHeader.length);
        final decrypted = await _decryptData(encryptedData);
        final list = jsonDecode(decrypted) as List;
        final models = list.map((e) => PasswordModel.fromMap(e as Map<String, dynamic>)).toList();

        for (final m in models) {
          await PasswordDatabase.instance.addPassword(m);
        }
        fetchAndInitializePasswords();

        _showCupertinoDialog(
          Get.context!,
          icon: CupertinoIcons.check_mark_circled,
          title: 'Restore Complete!',
          message: 'Imported ${models.length} password entries',
          primaryAction: 'OK',
        );
      }
    } catch (e) {
      _showCupertinoDialog(
        Get.context!,
        icon: CupertinoIcons.exclamationmark_circle,
        title: 'Import Failed',
        message: 'Invalid backup file or decryption error',
        primaryAction: 'OK',
      );
    }
  }

  Future<void> importFromCSV() async {
    if (kIsWeb) return;
    try {
      await FilePermissionService.requestStoragePermission();
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        dialogTitle: 'Select CSV File',
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final entries = _parseCSV(content);

        if (entries.isEmpty) {
          _showCupertinoDialog(
            Get.context!,
            icon: CupertinoIcons.exclamationmark_circle,
            title: 'No Entries Found',
            message: 'CSV file appears to be empty or invalid',
            primaryAction: 'OK',
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
          title: 'Import Complete!',
          message: 'Imported ${entries.length} password entries from CSV',
          primaryAction: 'OK',
        );
      }
    } catch (e) {
      _showCupertinoDialog(
        Get.context!,
        icon: CupertinoIcons.exclamationmark_circle,
        title: 'Import Failed',
        message: 'Invalid CSV format or file error',
        primaryAction: 'OK',
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

  Future<String> _encryptData(String plaintext) async {
    final key = await _getOrCreateEncryptionKey();
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return '${base64Encode(iv.bytes)}:${encrypted.base64}';
  }

  Future<String> _decryptData(String encryptedData) async {
    final parts = encryptedData.split(':');
    if (parts.length != 2) throw Exception('Invalid encrypted format');

    final iv = encrypt.IV.fromBase64(parts[0]);
    final encryptedText = parts[1];
    final key = await _getOrCreateEncryptionKey();
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    return encrypter.decrypt64(encryptedText, iv: iv);
  }

  Future<encrypt.Key> _getOrCreateEncryptionKey() async {
    String? keyBase64 = await _secureStorage.read(key: _keyName);
    if (keyBase64 == null) {
      final random = math.Random.secure();
      final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
      keyBase64 = base64Encode(keyBytes);
      await _secureStorage.write(key: _keyName, value: keyBase64);
    }
    return encrypt.Key.fromBase64(keyBase64);
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
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(message, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 15)),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text(primaryAction, style: TextStyle(color: iconColor, fontSize: 17)),
          ),
        ],
      ),
    );
  }
}

