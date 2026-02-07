// custom_appbar.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:password_manager/utils/consts.dart';

class CustomDashboardAppbarCupertino extends StatelessWidget implements ObstructingPreferredSizeWidget {
  final VoidCallback onSettingsTap;

  const CustomDashboardAppbarCupertino({super.key, required this.onSettingsTap});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final onSurfaceColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E);
    final backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    return CupertinoNavigationBar(
      backgroundColor: backgroundColor,
      padding: EdgeInsetsDirectional.only(
        start: AppConstVariables.mainPadding,
        end: AppConstVariables.mainPadding,
      ),
      middle: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'NeoPass',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: onSurfaceColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Secure. Simple. Neo.',
            style: TextStyle(
              fontSize: 11,
              color: primaryColor,
            ),
          ),
        ],
      ),
      trailing: GestureDetector(
        onTap: onSettingsTap,
        child: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            CupertinoIcons.settings,
            color: primaryColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}