import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProfileStatsWidget extends StatelessWidget {
  final Map<String, dynamic> riderData;

  const ProfileStatsWidget({super.key, required this.riderData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatCell(
            iconName: 'local_taxi',
            iconColor: AppTheme.primary,
            iconBg: AppTheme.primaryContainer,
            label: 'Total Trips',
            value: '${riderData['totalTrips']}',
          ),
          _buildDivider(),
          _StatCell(
            iconName: 'route',
            iconColor: AppTheme.accent,
            iconBg: AppTheme.accentContainer,
            label: 'Km Ridden',
            value: (riderData['totalKm'] as double).toStringAsFixed(0),
            unit: 'km',
          ),
          _buildDivider(),
          _StatCell(
            iconName: 'calendar_today',
            iconColor: const Color(0xFF7C3AED),
            iconBg: const Color(0xFFF3E8FF),
            label: 'Member Since',
            value: riderData['memberSince'],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 48,
      color: AppTheme.outlineVariantLight,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String iconName;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String? unit;

  const _StatCell({
    required this.iconName,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppTheme.onSurfaceMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
