import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:password_manager/modules/passcode/controller/passcode_controller.dart';

class PasscodeVerifyPage extends StatefulWidget {
  const PasscodeVerifyPage({super.key});

  @override
  State<PasscodeVerifyPage> createState() => _PasscodeVerifyPageState();
}

class _PasscodeVerifyPageState extends State<PasscodeVerifyPage>
    with SingleTickerProviderStateMixin {
  late final PasscodeController controller;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  bool _biometricAttempted = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = Get.find<PasscodeController>();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      if (mounted && !_biometricAttempted && controller.biometricEnabled.value) {
        _biometricAttempted = true;
        controller.attemptBiometricAuth();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (controller.isLoading.value) return;
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
        controller.deleteLastDigit();
      } else if (key == LogicalKeyboardKey.numpad0 || key.keyLabel == '0') {
        controller.addDigit('0');
      } else if (key == LogicalKeyboardKey.numpad1 || key.keyLabel == '1') {
        controller.addDigit('1');
      } else if (key == LogicalKeyboardKey.numpad2 || key.keyLabel == '2') {
        controller.addDigit('2');
      } else if (key == LogicalKeyboardKey.numpad3 || key.keyLabel == '3') {
        controller.addDigit('3');
      } else if (key == LogicalKeyboardKey.numpad4 || key.keyLabel == '4') {
        controller.addDigit('4');
      } else if (key == LogicalKeyboardKey.numpad5 || key.keyLabel == '5') {
        controller.addDigit('5');
      } else if (key == LogicalKeyboardKey.numpad6 || key.keyLabel == '6') {
        controller.addDigit('6');
      } else if (key == LogicalKeyboardKey.numpad7 || key.keyLabel == '7') {
        controller.addDigit('7');
      } else if (key == LogicalKeyboardKey.numpad8 || key.keyLabel == '8') {
        controller.addDigit('8');
      } else if (key == LogicalKeyboardKey.numpad9 || key.keyLabel == '9') {
        controller.addDigit('9');
      } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
        if (controller.inputDigits.length == 4) {
          controller.addDigit(''); // triggers _processInput
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final primaryText = theme.textTheme.navLargeTitleTextStyle.color ??
        (isDark ? Colors.white : Colors.black);
    final secondaryText = primaryText.withOpacity(0.6);
    final keyBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final errorColor = CupertinoColors.systemRed;
    final keySize = isSmallScreen ? 68.0 : 76.0;

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      child: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: _handleKeyEvent,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth > 600 ? 80.0 : 24.0;
              final topSpacing = isSmallScreen ? 32.0 : 64.0;
              final dotSpacing = isSmallScreen ? 40.0 : 64.0;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    SizedBox(height: topSpacing),
                    Text(
                      'Unlock NeoPass',
                      style: theme.textTheme.navLargeTitleTextStyle.copyWith(
                        fontSize: isSmallScreen ? 28 : 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter your passcode to continue',
                      style: theme.textTheme.textStyle.copyWith(
                        color: secondaryText,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: dotSpacing),
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            math.sin(_shakeAnimation.value * 2 * math.pi) *
                                _shakeAnimation.value,
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: Obx(
                            () => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            final filled = index < controller.inputDigits.length;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              width: isSmallScreen ? 12 : 16,
                              height: isSmallScreen ? 12 : 16,
                              margin: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 8 : 12,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: filled ? primaryText : Colors.transparent,
                                border: Border.all(
                                  color: filled
                                      ? primaryText
                                      : primaryText.withOpacity(0.3),
                                  width: filled ? 2 : 1.5,
                                ),
                                boxShadow: filled
                                    ? [
                                  BoxShadow(
                                    color: primaryText.withOpacity(0.2),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                                    : null,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(
                          () => AnimatedOpacity(
                        opacity: controller.statusMessage.value.isEmpty ? 0 : 1,
                        duration: const Duration(milliseconds: 250),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.exclamationmark_circle_fill,
                                size: 16,
                                color: errorColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                controller.statusMessage.value,
                                style: theme.textTheme.textStyle.copyWith(
                                  color: errorColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Obx(
                          () => controller.biometricEnabled.value && !Platform.isWindows && !Platform.isLinux
                          ? Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 16),
                        child: Center(
                          child: _BiometricButton(
                            onTap: controller.attemptBiometricAuth,
                            bg: keyBg,
                            color: primaryText,
                            size: keySize,
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),
                    const Spacer(),
                    _Keypad(
                      controller: controller,
                      keyBg: keyBg,
                      textColor: primaryText,
                      isSmallScreen: isSmallScreen,
                      onError: _triggerShake,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BiometricButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color bg;
  final Color color;
  final double size;

  const _BiometricButton({
    required this.onTap,
    required this.bg,
    required this.color,
    required this.size,
  });

  @override
  State<_BiometricButton> createState() => _BiometricButtonState();
}

class _BiometricButtonState extends State<_BiometricButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.bg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.bg.withOpacity(0.92),
                  border: Border.all(
                    color: widget.color.withOpacity(0.08),
                    width: 0.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.fingerprint,
                  size: 28,
                  color: widget.color.withOpacity(0.9),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  final PasscodeController controller;
  final Color keyBg;
  final Color textColor;
  final bool isSmallScreen;
  final VoidCallback onError;

  const _Keypad({
    required this.controller,
    required this.keyBg,
    required this.textColor,
    required this.isSmallScreen,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    final keySize = isSmallScreen ? 68.0 : 76.0;
    final keySpacing = isSmallScreen ? 12.0 : 16.0;

    return Column(
      children: [
        for (int row = 0; row < 3; row++)
          Padding(
            padding: EdgeInsets.only(bottom: keySpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (col) {
                final number = row * 3 + col + 1;
                return _Key(
                  label: '$number',
                  onTap: () => controller.addDigit('$number'),
                  bg: keyBg,
                  color: textColor,
                  size: keySize,
                );
              }),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: keySize + 8),
            _Key(
              label: '0',
              onTap: () => controller.addDigit('0'),
              bg: keyBg,
              color: textColor,
              size: keySize,
            ),
            const SizedBox(width: 8),
            _DeleteKey(
              onTap: controller.deleteLastDigit,
              bg: keyBg,
              color: textColor,
              size: keySize,
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color bg;
  final Color color;
  final double size;

  const _Key({
    required this.label,
    required this.onTap,
    required this.bg,
    required this.color,
    required this.size,
  });

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.bg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.bg.withOpacity(0.92),
                  border: Border.all(
                    color: widget.color.withOpacity(0.08),
                    width: 0.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: widget.color,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteKey extends StatefulWidget {
  final VoidCallback onTap;
  final Color bg;
  final Color color;
  final double size;

  const _DeleteKey({
    required this.onTap,
    required this.bg,
    required this.color,
    required this.size,
  });

  @override
  State<_DeleteKey> createState() => _DeleteKeyState();
}

class _DeleteKeyState extends State<_DeleteKey>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.bg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.bg.withOpacity(0.92),
                  border: Border.all(
                    color: widget.color.withOpacity(0.08),
                    width: 0.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  CupertinoIcons.delete_left,
                  size: 26,
                  color: widget.color.withOpacity(0.9),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}