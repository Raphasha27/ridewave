import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../widgets/app_navigation.dart';
import './widgets/profile_activity_chart_widget.dart';
import './widgets/profile_hero_widget.dart';
import './widgets/profile_info_section_widget.dart';
import './widgets/profile_preferences_widget.dart';
import './widgets/profile_saved_places_widget.dart';
import './widgets/profile_sos_contacts_widget.dart';
import './widgets/profile_stats_widget.dart';

// TODO: Replace with Riverpod/Bloc for production state management
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _navIndex = 3;
  bool _isEditing = false;

  final Map<String, dynamic> _riderData = {
    'name': 'Marcus Osei-Bonsu',
    'phone': '+1 (555) 000-0001',
    'email': 'marcus.osei@ridewave.app',
    'avatarUrl':
        'https://img.rocket.new/generatedImages/rocket_gen_img_11add7eb4-1763294437588.png',
    'avatarSemanticLabel':
        'Professional headshot of a young Black man with short hair wearing a dark jacket',
    'rating': 4.87,
    'totalTrips': 247,
    'totalKm': 1842.5,
    'memberSince': 'Mar 2023',
    'isVerified': true,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: isTablet
            ? _buildTabletLayout(context, theme)
            : _buildPhoneLayout(context, theme),
      ),
      bottomNavigationBar: SafeArea(
        child: AppNavigation(
          currentIndex: _navIndex,
          onTap: (i) {
            setState(() => _navIndex = i);
            if (i == 2) Navigator.pushNamed(context, AppRoutes.paymentsScreen);
            if (i == 0) {
              Navigator.pushNamed(context, AppRoutes.signUpLoginScreen);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(BuildContext context, ThemeData theme) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(theme),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                ProfileStatsWidget(riderData: _riderData),
                const SizedBox(height: 20),
                ProfileActivityChartWidget(),
                const SizedBox(height: 20),
                ProfileInfoSectionWidget(
                  riderData: _riderData,
                  isEditing: _isEditing,
                  onEditToggle: () => setState(() => _isEditing = !_isEditing),
                ),
                const SizedBox(height: 16),
                const ProfileSavedPlacesWidget(),
                const SizedBox(height: 16),
                const ProfileSosContactsWidget(),
                const SizedBox(height: 16),
                const ProfilePreferencesWidget(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(theme),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ProfileStatsWidget(riderData: _riderData),
                      const SizedBox(height: 20),
                      ProfileActivityChartWidget(),
                      const SizedBox(height: 20),
                      ProfileInfoSectionWidget(
                        riderData: _riderData,
                        isEditing: _isEditing,
                        onEditToggle: () =>
                            setState(() => _isEditing = !_isEditing),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const ProfileSavedPlacesWidget(),
                const SizedBox(height: 16),
                const ProfileSosContactsWidget(),
                const SizedBox(height: 16),
                const ProfilePreferencesWidget(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.primary,
      scrolledUnderElevation: 0,
      elevation: 0,
      leading: IconButton(
        icon: const CustomIconWidget(
          iconName: 'arrow_back',
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const CustomIconWidget(
            iconName: 'settings',
            color: Colors.white,
            size: 22,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const CustomIconWidget(
            iconName: 'notifications',
            color: Colors.white,
            size: 22,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ProfileHeroWidget(riderData: _riderData),
        ),
      ),
      title: Text(
        'My Profile',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
