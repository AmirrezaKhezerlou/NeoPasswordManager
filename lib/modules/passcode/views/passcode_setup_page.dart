import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:password_manager/modules/passcode/controller/passcode_controller.dart';

class PasscodeSetupPage extends StatefulWidget {
  const PasscodeSetupPage({super.key});

  @override
  State<PasscodeSetupPage> createState() => _PasscodeSetupPageState();
}

class _PasscodeSetupPageState extends State<PasscodeSetupPage> with TickerProviderStateMixin {
  late final PasscodeController controller;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  final FocusNode _keyboardFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = Get.find<PasscodeController>();
    controller.clearInput();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeIn))
        .animate(_shakeController);

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _keyboardFocus.requestFocus());
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _keyboardFocus.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
    HapticFeedback.vibrate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? CupertinoColors.white : CupertinoColors.black;
    final accentColor = theme.primaryColor;

    return CupertinoPageScaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: _BlurredCircle(color: accentColor.withOpacity(0.08)),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Column(
                    key: ValueKey(controller.tempPasscode.value.isEmpty),
                    children: [
                      Text(
                        controller.tempPasscode.value.isEmpty ? 'create_passcode'.tr : 'confirm_passcode'.tr,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Text(
                          controller.tempPasscode.value.isEmpty ? 'set_passcode_description'.tr : 're_enter_passcode_confirm'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: primaryColor.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 48),
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    final double offset = math.sin(_shakeAnimation.value * 4 * math.pi) * 8;
                    return Transform.translate(offset: Offset(offset, 0), child: child);
                  },
                  child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        4,
                            (index) => _DotIndicator(
                          isFilled: index < controller.inputDigits.length,
                          color: primaryColor,
                        )),
                  )),
                ),
                const SizedBox(height: 32),
                Obx(() => AnimatedOpacity(
                  opacity: controller.statusMessage.value.isEmpty ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    controller.statusMessage.value.tr,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
                const Spacer(flex: 2),
                _PasscodeKeypad(
                  onDigit: (val) {
                    HapticFeedback.selectionClick();
                    controller.addDigit(val);
                  },
                  onDelete: () {
                    HapticFeedback.lightImpact();
                    controller.deleteLastDigit();
                  },
                  primaryColor: primaryColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasscodeKeypad extends StatelessWidget {
  final Function(String) onDigit;
  final VoidCallback onDelete;
  final Color primaryColor;
  final bool isDark;

  const _PasscodeKeypad({
    required this.onDigit,
    required this.onDelete,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonSize = size.height < 700 ? 72.0 : 80.0;
    final spacing = size.height < 700 ? 12.0 : 20.0;

    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9']
        ])
          Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row
                  .map((d) => _KeyButton(
                label: d,
                onTap: () => onDigit(d),
                isDark: isDark,
                size: buttonSize,
              ))
                  .toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: buttonSize + 24),
            _KeyButton(label: '0', onTap: () => onDigit('0'), isDark: isDark, size: buttonSize),
            Container(
              width: buttonSize,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onDelete,
                child: Icon(CupertinoIcons.delete_left_fill, color: primaryColor.withOpacity(0.6), size: 28),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final double size;

  const _KeyButton({
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.size,
  });

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(_anim);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);

    return GestureDetector(
      onTapDown: (_) => _anim.forward(),
      onTapUp: (_) {
        _anim.reverse();
        widget.onTap();
      },
      onTapCancel: () => _anim.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final bool isFilled;
  final Color color;

  const _DotIndicator({required this.isFilled, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 14),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? color : Colors.transparent,
        border: Border.all(color: color.withOpacity(0.2), width: 2),
        boxShadow: isFilled
            ? [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ]
            : [],
      ),
    );
  }
}

class _BlurredCircle extends StatelessWidget {
  final Color color;
  const _BlurredCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container()),
    );
  }
}