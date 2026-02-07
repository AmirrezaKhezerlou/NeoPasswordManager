import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class FilePermissionService {
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdk = androidInfo.version.sdkInt;

    if (sdk >= 33) {
      bool granted = await _check([
        Permission.manageExternalStorage,
        Permission.photos,
        Permission.videos,
        Permission.audio,
      ]);
      if (!granted) {
        await _request([
          Permission.manageExternalStorage,
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ]);
        granted = await _check([
          Permission.manageExternalStorage,
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ]);
      }
      return granted;
    } else if (sdk >= 30) {
      bool granted = await _check([Permission.manageExternalStorage]);
      if (!granted) {
        await _request([Permission.manageExternalStorage]);
        granted = await _check([Permission.manageExternalStorage]);
      }
      return granted;
    } else {
      bool granted = await _check([Permission.storage]);
      if (!granted) {
        await _request([Permission.storage]);
        granted = await _check([Permission.storage]);
      }
      return granted;
    }
  }

  static Future<bool> _check(List<Permission> perms) async {
    for (var p in perms) {
      if (await p.isGranted) return true;
    }
    return false;
  }

  static Future<void> _request(List<Permission> perms) async {
    for (var p in perms) {
      if (await p.isDenied || await p.isRestricted || await p.isLimited) {
        await p.request();
      }
    }
  }
}
