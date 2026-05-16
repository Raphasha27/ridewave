import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import './custom_icon_widget.dart';

// TODO: Replace with Riverpod/Bloc for production state management
class AppNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    if (isTablet) {
      return _buildNavigationRail(context);
    }
    return _buildFloatingPillNav(context);
  }

  Widget _buildFloatingPillNav(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withAlpha(89),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              iconName: currentIndex == 0 ? 'home' : 'home_outlined',
              label: 'Home',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              iconName: currentIndex == 1 ? 'history' : 'history',
              label: 'Trips',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              iconName: currentIndex == 2 ? 'payment' : 'payment_outlined',
              label: 'Pay',
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _NavItem(
              iconName: currentIndex == 3 ? 'person' : 'person_outlined',
              label: 'Profile',
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    return NavigationRail(
      backgroundColor: AppTheme.primary,
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      labelType: NavigationRailLabelType.all,
      selectedLabelTextStyle: GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: GoogleFonts.plusJakartaSans(
        color: Colors.white54,
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
      indicatorColor: Colors.white.withAlpha(38),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined, color: Colors.white54),
          selectedIcon: Icon(Icons.home_rounded, color: Colors.white),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.history_rounded, color: Colors.white54),
          selectedIcon: Icon(Icons.history_rounded, color: Colors.white),
          label: Text('Trips'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.payment_outlined, color: Colors.white54),
          selectedIcon: Icon(Icons.payment_rounded, color: Colors.white),
          label: Text('Pay'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline_rounded, color: Colors.white54),
          selectedIcon: Icon(Icons.person_rounded, color: Colors.white),
          label: Text('Profile'),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final String iconName;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.iconName,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withAlpha(38) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isActive ? Colors.white : Colors.white54,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? Colors.white : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
