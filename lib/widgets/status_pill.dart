// lib/widgets/status_pill.dart

import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';

enum PillType {
  primary,   // 진행중 - midnight text + grain fill
  alert,     // 모집중/임박 - accent outline + transparent
  inactive,  // 예정/종료 - grain outline + transparent
}

class StatusPill extends StatelessWidget {
  final String label;
  final PillType type;

  const StatusPill({
    super.key,
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color fillColor;
    Color borderColor;
    Color textColor;

    switch (type) {
      case PillType.primary:
        fillColor = AppColors.success.withOpacity(0.15);
        borderColor = AppColors.success;
        textColor = AppColors.success;
        break;
      case PillType.alert:
        fillColor = AppColors.alert.withOpacity(0.15);
        borderColor = AppColors.alert;
        textColor = AppColors.alert;
        break;
      case PillType.inactive:
        fillColor = Colors.transparent;
        borderColor = AppColors.grain;
        textColor = AppColors.accent.withOpacity(0.6);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fillColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(20), // pill shape
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
