import 'package:google_fonts/google_fonts.dart';
import '../../core/app_export.dart';
import '../../widgets/app_navigation.dart';
import '../../core/services/mock_database_service.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> with SingleTickerProviderStateMixin {
  final int _navIndex = 1;
  late TabController _tabController;
  final MockDatabaseService _db = MockDatabaseService();

  final List<Map<String, dynamic>> _cancelledTrips = [
    {
      'id': 'trip_c1',
      'date': '08 May 2026, 12:10',
      'driver': 'John Smith',
      'driverRating': 4.75,
      'car': 'Black Hyundai Accent',
      'cost': 'R 0.00',
      'distance': '0.0 km',
      'duration': '0 mins',
      'pickup': 'Hatfield Plaza, Hatfield',
      'dropoff': 'Centurion Mall, Centurion',
      'type': 'Wave Go',
      'reason': 'Cancelled by Passenger',
    },
  ];

  int get tripsDone => _db.completedTrips.value.length + 244;

  String get totalSpent {
    double base = 8168.00; // 8420 - 72 - 125 - 55
    double sum = 0.0;
    for (var trip in _db.completedTrips.value) {
      String costStr = trip['cost'].toString().replaceAll('R', '').replaceAll(' ', '');
      sum += double.tryParse(costStr) ?? 0.0;
    }
    return 'R ${sum > 0 ? (base + sum).toStringAsFixed(2) : '8,420'}';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Listen to database changes to trigger setStates
    _db.completedTrips.addListener(_onDbChanged);
  }

  @override
  void dispose() {
    _db.completedTrips.removeListener(_onDbChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onDbChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Trips'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: _db.completedTrips,
          builder: (context, trips, child) {
            return isTablet
                ? _buildTabletLayout(context, theme, trips)
                : _buildPhoneLayout(context, theme, trips);
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: AppNavigation(
          currentIndex: _navIndex,
          onTap: (i) {
            if (i == 0) Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
            if (i == 2) Navigator.pushReplacementNamed(context, AppRoutes.paymentsScreen);
            if (i == 3) Navigator.pushReplacementNamed(context, AppRoutes.profileScreen);
          },
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(BuildContext context, ThemeData theme, List<Map<String, dynamic>> completedTrips) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                _buildStatsSection(),
                const SizedBox(height: 20),
                _buildSpendingChartCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TripsTabBarDelegate(
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
                Tab(text: 'Completed'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTripsList(completedTrips, false),
          _buildTripsList(_cancelledTrips, true),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, ThemeData theme, List<Map<String, dynamic>> completedTrips) {
    return Row(
      children: [
        // Left Column: Stats & Chart
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildStatsSection(),
                const SizedBox(height: 20),
                _buildSpendingChartCard(),
              ],
            ),
          ),
        ),
        // Right Column: Trip History List
        Expanded(
          flex: 5,
          child: Column(
            children: [
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.onSurfaceMuted,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTripsList(completedTrips, false),
                    _buildTripsList(_cancelledTrips, true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Stats Counters
  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Trips Done',
            value: '$tripsDone',
            icon: 'local_taxi',
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Total Spent',
            value: totalSpent,
            icon: 'payment',
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Your Rating',
            value: '4.87 ★',
            icon: 'star',
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppTheme.onSurfaceMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Spending Chart
  Widget _buildSpendingChartCard() {
    final List<Map<String, dynamic>> monthlySpending = [
      {'month': 'Jan', 'value': 400.0, 'rides': 15},
      {'month': 'Feb', 'value': 650.0, 'rides': 22},
      {'month': 'Mar', 'value': 980.0, 'rides': 32},
      {'month': 'Apr', 'value': 820.0, 'rides': 27},
      {'month': 'May', 'value': 1200.0, 'rides': 38},
    ];

    double maxVal = 1200.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Spending Overview',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              Text(
                'R 4,050 total (YTD)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Custom Bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: monthlySpending.map((data) {
              double ratio = (data['value'] as double) / maxVal;
              double barHeight = 90 * ratio;
              return Column(
                children: [
                  Text(
                    'R ${(data['value'] as double).toInt()}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    height: barHeight,
                    width: 24,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryLight, AppTheme.primary],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['month'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Trip List view
  Widget _buildTripsList(List<Map<String, dynamic>> trips, bool isCancelled) {
    if (trips.isEmpty) {
      return const EmptyStateWidget(
        title: 'No Trips Found',
        message: 'You have not booked any rides in this category.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trip['date'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                  Text(
                    trip['cost'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isCancelled ? AppTheme.onSurfaceMuted : AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Address Timeline
              _buildAddressTimeline(trip['pickup'] as String, trip['dropoff'] as String),
              const SizedBox(height: 14),
              
              Divider(color: AppTheme.outlineVariantLight),
              const SizedBox(height: 10),
              
              // Driver and Vehicle detail row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      shape: BoxShape.circle,
                    ),
                    child: const CustomIconWidget(
                      iconName: 'person',
                      color: AppTheme.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip['driver'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          trip['car'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppTheme.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Ride category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trip['type'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (isCancelled && trip.containsKey('reason')) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppTheme.error, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      trip['reason'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 14),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Downloading invoice receipt...')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.outlineLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'Receipt',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'Book Again',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Address Timeline UI
  Widget _buildAddressTimeline(String pickup, String dropoff) {
    return Column(
      children: [
        Row(
          children: [
            Column(
              children: [
                const Icon(Icons.circle_outlined, color: AppTheme.accentDark, size: 14),
                Container(
                  width: 2,
                  height: 24,
                  color: AppTheme.outlineLight,
                ),
                const Icon(Icons.location_on_rounded, color: AppTheme.error, size: 14),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pickup,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    dropoff,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TripsTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TripsTabBarDelegate(this.tabBar);

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
  bool shouldRebuild(_TripsTabBarDelegate oldDelegate) => false;
}
