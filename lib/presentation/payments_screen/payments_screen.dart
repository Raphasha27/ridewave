import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../widgets/in_app_notification_banner_widget.dart';
import '../../core/services/mock_database_service.dart';
import '../../widgets/app_navigation.dart';
import './widgets/add_payment_method_sheet_widget.dart';
import './widgets/payment_methods_list_widget.dart';
import './widgets/payment_step_indicator_widget.dart';
import './widgets/spending_chart_widget.dart';
import './widgets/transactions_list_widget.dart';
import './widgets/wallet_balance_hero_widget.dart';

// TODO: Replace with Riverpod/Bloc for production state management
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 2;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddPaymentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AddPaymentMethodSheetWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          SafeArea(
            child: isTablet
                ? _buildTabletLayout(context)
                : _buildPhoneLayout(context),
          ),
          
          // Global In-App Banner Notification Overlay
          ValueListenableBuilder<Map<String, String>?>(
            valueListenable: MockDatabaseService().activeNotification,
            builder: (context, notification, child) {
              if (notification == null) return const SizedBox.shrink();
              return Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: InAppNotificationBannerWidget(
                  title: notification['title'] ?? 'Notification',
                  body: notification['body'] ?? '',
                  iconName: notification['icon'] ?? 'notifications',
                  onClose: () {
                    MockDatabaseService().activeNotification.value = null;
                  },
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: AppNavigation(
          currentIndex: _navIndex,
          onTap: (i) {
            if (i == 0) Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
            if (i == 1) Navigator.pushReplacementNamed(context, AppRoutes.tripsScreen);
            if (i == 3) Navigator.pushReplacementNamed(context, AppRoutes.profileScreen);
          },
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _buildSliverAppBar(innerBoxIsScrolled),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const WalletBalanceHeroWidget(),
                const SizedBox(height: 20),
                // Step indicator (extracted from reference image)
                const PaymentStepIndicatorWidget(),
                const SizedBox(height: 20),
                const SpendingChartWidget(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.onSurfaceMuted,
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: 'Payment Methods'),
                Tab(text: 'Transactions'),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [_buildMethodsTab(), _buildTransactionsTab()],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const WalletBalanceHeroWidget(),
                const SizedBox(height: 20),
                const PaymentStepIndicatorWidget(),
                const SizedBox(height: 20),
                const SpendingChartWidget(),
                const SizedBox(height: 20),
                PaymentMethodsListWidget(onAddTap: _showAddPaymentSheet),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Recent Transactions',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Expanded(child: TransactionsListWidget()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: PaymentMethodsListWidget(onAddTap: _showAddPaymentSheet),
    );
  }

  Widget _buildTransactionsTab() {
    return const TransactionsListWidget();
  }

  SliverAppBar _buildSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
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
      title: Text(
        'Payments',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const CustomIconWidget(
            iconName: 'history',
            color: Colors.white,
            size: 22,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppTheme.backgroundLight,
      child: Column(
        children: [
          tabBar,
          Divider(color: AppTheme.outlineVariantLight, height: 1),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
