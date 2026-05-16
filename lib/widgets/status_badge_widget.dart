import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum RideStatus {
  requested,
  accepted,
  arriving,
  arrived,
  started,
  completed,
  cancelled,
  pending,
}

class StatusBadgeWidget extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final RideStatus? status;
  final double? fontSize;

  const StatusBadgeWidget({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.status,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize ?? 11,
          fontWeight: FontWeight.w600,
          color: colors.$2,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  (Color, Color) _resolveColors() {
    if (backgroundColor != null && textColor != null) {
      return (backgroundColor!, textColor!);
    }
    switch (status) {
      case RideStatus.requested:
        return (const Color(0xFFFFF3E0), AppTheme.warning);
      case RideStatus.accepted:
        return (const Color(0xFFE3F2FD), const Color(0xFF1565C0));
      case RideStatus.arriving:
        return (const Color(0xFFE8F5E9), AppTheme.accent);
      case RideStatus.arrived:
        return (AppTheme.accentContainer, AppTheme.accentDark);
      case RideStatus.started:
        return (AppTheme.primaryContainer, AppTheme.primary);
      case RideStatus.completed:
        return (const Color(0xFFE8F5E9), AppTheme.success);
      case RideStatus.cancelled:
        return (AppTheme.errorContainer, AppTheme.error);
      case RideStatus.pending:
        return (const Color(0xFFF5F5F5), const Color(0xFF757575));
      default:
        return (const Color(0xFFF5F5F5), const Color(0xFF757575));
    }
  }
}
