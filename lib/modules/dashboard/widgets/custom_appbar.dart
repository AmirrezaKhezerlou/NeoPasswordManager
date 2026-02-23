import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:password_manager/utils/consts.dart';

class CustomDashboardAppbarCupertino extends StatelessWidget implements ObstructingPreferredSizeWidget {
  final VoidCallback onSettingsTap;

  const CustomDashboardAppbarCupertino({super.key, required this.onSettingsTap});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  bool shouldFullyObstruct(BuildContext context) => true;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final onSurfaceColor = isDark ? const Color(0xFFE5E5EA) : const Color(0xFF1C1C1E);
    final backgroundColor = isDark ? const Color(0xFF000000).withOpacity(0.8) : const Color(0xFFF2F2F7).withOpacity(0.8);

    return CupertinoNavigationBar(
      automaticallyImplyLeading: false,
      transitionBetweenRoutes: true,
      backgroundColor: backgroundColor,
      border: null,
      padding: EdgeInsetsDirectional.only(
        start: AppConstVariables.mainPadding,
        end: AppConstVariables.mainPadding,
      ),
      middle: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NeoPass',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: onSurfaceColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              'app_tagline'.tr.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 0,
        onPressed: onSettingsTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ],
          ),
          child: Icon(
            CupertinoIcons.settings_solid,
            color: primaryColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}