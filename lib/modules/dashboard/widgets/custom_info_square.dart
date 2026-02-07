import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class InfoSquareWidgetCupertino extends StatelessWidget {
  final int count;
  final String title;
  final Color primaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;

  const InfoSquareWidgetCupertino({
    super.key,
    required this.count,
    required this.title,
    required this.primaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (Get.width - 48) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: onSurfaceColor,
            ),
          ),
        ],
      ),
    );
  }
}