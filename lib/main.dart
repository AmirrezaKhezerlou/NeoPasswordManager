import 'dart:io' show Platform, exit;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_selection_intent/text_selection_intent.dart';
import 'package:window_manager/window_manager.dart';
import 'modules/passcode/controller/passcode_controller.dart';
import 'services/sec_service/app_security_service.dart';
import 'utils/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: const Size(375, 812),
      minimumSize: const Size(375, 812),
      maximumSize: const Size(375, 812),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final securityService = AppSecurityService();
  securityService.initialize();

  Get.put(ThemeController());
  Get.put(PasscodeController());
  Get.put(SharedTextHandlerService());
  if (Platform.isAndroid) {
    TextSelectionIntent.listen((text) {
      if (text.isNotEmpty && !Get.isRegistered<SharedText>()) {
        Get.put(SharedText(text));
      }
    });
  }

  runApp(const MyApp());
}

class SharedText extends GetxService {
  final String text;
  SharedText(this.text);
}

class SharedTextHandlerService extends GetxService {
  bool _handled = false;

  bool get hasData => !_handled && Get.isRegistered<SharedText>();

  String take() {
    _handled = true;
    final text = Get.find<SharedText>().text;
    Get.delete<SharedText>();
    return text;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetCupertinoApp(
          debugShowCheckedModeBanner: false,
          title: 'NeoPass',
          theme: themeController.themeMode.value == ThemeMode.dark
              ? const CupertinoThemeData(brightness: Brightness.dark)
              : const CupertinoThemeData(brightness: Brightness.light),
          home: Platform.isWindows
              ? const WindowsFrameWrapper(child: PasscodeGateKeeper())
              : const PasscodeGateKeeper(),
        );
      },
    );
  }
}

class WindowsFrameWrapper extends StatelessWidget {
  final Widget child;
  const WindowsFrameWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? const Color(0xFF1C1C1C) : const Color(0xFFF2F2F7);
    final iconColor = isDark ? Colors.white54 : Colors.black54;

    return Column(
      children: [
        SizedBox(
          height: 32,
          child: MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: GestureDetector(
              onTapDown: (_) => windowManager.startDragging(),
              child: Container(
                color: barColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                      onPressed: windowManager.minimize,
                      icon: Icon(CupertinoIcons.minus, size: 16, color: iconColor),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                      onPressed: () => Get.defaultDialog(
                        title: 'Exit',
                        content: const Text('Are you sure you want to exit?'),
                        confirm: CupertinoDialogAction(
                          onPressed: () => exit(0),
                          child: const Text('Yes'),
                        ),
                        cancel: CupertinoDialogAction(
                          onPressed: Get.back,
                          child: const Text('No'),
                        ),
                      ),
                      icon: Icon(CupertinoIcons.xmark, size: 16, color: iconColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class PasscodeGateKeeper extends StatelessWidget {
  const PasscodeGateKeeper({super.key});

  @override
  Widget build(BuildContext context) {
    final passcodeCtrl = Get.find<PasscodeController>();
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final backgroundColor =
    isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);

    return Obx(() {
      if (passcodeCtrl.isLoading.value) {
        return Container(
          color: backgroundColor,
          child: const Center(
            child: CupertinoActivityIndicator(radius: 20),
          ),
        );
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        passcodeCtrl.smartLogin();
      });

      return Container(color: backgroundColor);
    });
  }
}