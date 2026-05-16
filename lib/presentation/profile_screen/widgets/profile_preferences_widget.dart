import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProfilePreferencesWidget extends StatefulWidget {
  const ProfilePreferencesWidget({super.key});

  @override
  State<ProfilePreferencesWidget> createState() =>
      _ProfilePreferencesWidgetState();
}

class _ProfilePreferencesWidgetState extends State<ProfilePreferencesWidget> {
  // TODO: Replace with Riverpod/Bloc for production state management
  bool _pushNotifications = true;
  bool _smsAlerts = true;
  bool _shareRideStatus = false;
  bool _maskedCalls = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(
            color: const Color(0xFF7C3AED).withAlpha(153),
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Text(
                  'Preferences',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppTheme.outlineVariantLight, height: 1),
          _PreferenceToggle(
            iconName: 'notifications',
            iconColor: const Color(0xFF7C3AED),
            iconBg: const Color(0xFFF3E8FF),
            label: 'Push Notifications',
            subtitle: 'Ride updates, promos, alerts',
            value: _pushNotifications,
            onChanged: (v) => setState(() => _pushNotifications = v),
          ),
          Divider(color: AppTheme.outlineVariantLight, height: 1, indent: 74),
          _PreferenceToggle(
            iconName: 'message',
            iconColor: AppTheme.accent,
            iconBg: AppTheme.accentContainer,
            label: 'SMS Alerts',
            subtitle: 'OTP, driver arrival, trip end',
            value: _smsAlerts,
            onChanged: (v) => setState(() => _smsAlerts = v),
          ),
          Divider(color: AppTheme.outlineVariantLight, height: 1, indent: 74),
          _PreferenceToggle(
            iconName: 'share',
            iconColor: const Color(0xFF0284C7),
            iconBg: const Color(0xFFE0F2FE),
            label: 'Share Ride Status',
            subtitle: 'Auto-share trip with contacts',
            value: _shareRideStatus,
            onChanged: (v) => setState(() => _shareRideStatus = v),
          ),
          Divider(color: AppTheme.outlineVariantLight, height: 1, indent: 74),
          _PreferenceToggle(
            iconName: 'phone',
            iconColor: AppTheme.primary,
            iconBg: AppTheme.primaryContainer,
            label: 'Masked Calls',
            subtitle: 'Hide your number from driver',
            value: _maskedCalls,
            onChanged: (v) => setState(() => _maskedCalls = v),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PreferenceToggle extends StatelessWidget {
  final String iconName;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceToggle({
    required this.iconName,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: iconColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.accent,
            activeTrackColor: AppTheme.accentContainer,
            inactiveThumbColor: AppTheme.onSurfaceMuted,
            inactiveTrackColor: AppTheme.surfaceVariantLight,
          ),
        ],
      ),
    );
  }
}
