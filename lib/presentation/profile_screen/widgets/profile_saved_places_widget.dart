import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProfileSavedPlacesWidget extends StatelessWidget {
  const ProfileSavedPlacesWidget({super.key});

  static final List<Map<String, dynamic>> _savedPlacesMaps = [
    {
      'icon': 'home',
      'iconColor': 0xFF1A1A2E,
      'iconBg': 0xFFE8E8FF,
      'label': 'Home',
      'address': '2847 Maple Grove Drive, Austin, TX 78701',
    },
    {
      'icon': 'work',
      'iconColor': 0xFF4CAF50,
      'iconBg': 0xFFE8F5E9,
      'label': 'Work',
      'address': '500 Congress Ave, Suite 200, Austin, TX 78701',
    },
    {
      'icon': 'favorite',
      'iconColor': 0xFFB91C1C,
      'iconBg': 0xFFFFEBEE,
      'label': 'Gym',
      'address': '1200 S Lamar Blvd, Austin, TX 78704',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(color: AppTheme.accent.withAlpha(153), width: 3),
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
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved Places',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Add saved place
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.accentContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Center(
                      child: CustomIconWidget(
                        iconName: 'add',
                        color: AppTheme.accentDark,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppTheme.outlineVariantLight, height: 1),
          ...List.generate(_savedPlacesMaps.length, (i) {
            final place = _savedPlacesMaps[i];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(place['iconBg'] as int),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: place['icon'] as String,
                            color: Color(place['iconColor'] as int),
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
                              place['label'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              place['address'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppTheme.onSurfaceMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const CustomIconWidget(
                        iconName: 'chevron_right',
                        color: AppTheme.onSurfaceMuted,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                if (i < _savedPlacesMaps.length - 1)
                  Divider(
                    color: AppTheme.outlineVariantLight,
                    height: 1,
                    indent: 74,
                  ),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
