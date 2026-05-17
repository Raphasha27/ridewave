import 'dart:async';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_export.dart';
import '../../core/services/mock_database_service.dart';
import '../../widgets/voip_call_overlay_widget.dart';
import '../../widgets/simulated_chat_sheet_widget.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> with TickerProviderStateMixin {
  final MockDatabaseService _db = MockDatabaseService();
  
  // Simulated Map Positions & Drift
  late AnimationController _pulseController;
  late AnimationController _navigationProgressController;
  Timer? _mockRequestTimer;
  int _incomingCountdown = 15;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _navigationProgressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    // Watch database for active jobs
    _db.isDriverOnline.addListener(_onOnlineStateChanged);
    _db.activeDriverStatus.addListener(_onStatusChanged);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _navigationProgressController.dispose();
    _db.isDriverOnline.removeListener(_onOnlineStateChanged);
    _db.activeDriverStatus.removeListener(_onStatusChanged);
    _mockRequestTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onOnlineStateChanged() {
    setState(() {});
    if (_db.isDriverOnline.value && _db.activeDriverStatus.value == 'idle') {
      // If driver goes online and has no job, trigger a simulated incoming job after 4 seconds
      _mockRequestTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _db.isDriverOnline.value && _db.activeDriverStatus.value == 'idle') {
          _db.createBooking(
            destination: 'Union Buildings, Arcadia',
            rideType: 'wave_go',
            price: 'R 65.00',
            eta: '3 mins',
          );
        }
      });
    } else {
      _mockRequestTimer?.cancel();
    }
  }

  void _onStatusChanged() {
    setState(() {});
    if (_db.activeDriverStatus.value == 'offering') {
      _startCountdown();
    } else {
      _countdownTimer?.cancel();
    }
  }

  void _startCountdown() {
    setState(() => _incomingCountdown = 15);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_incomingCountdown > 1) {
        setState(() => _incomingCountdown--);
      } else {
        _countdownTimer?.cancel();
        _db.cancelActiveJob(); // Driver missed job offer
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job offer expired')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOnline = _db.isDriverOnline.value;
    final status = _db.activeDriverStatus.value;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A), // Dark mode portal base
      body: Stack(
        children: [
          // 1. Dark Mode Vector Map surge painter
          Positioned.fill(
            child: _buildDriverMapCanvas(),
          ),

          // 2. Navigation Instructions Overlay Header
          if (status == 'navigating_pickup' || status == 'on_trip')
            Positioned(
              top: 54,
              left: 20,
              right: 20,
              child: _buildNavigationHeaderOverlay(theme, status),
            ),

          // 3. Driver Online/Offline Top Controls
          if (status == 'idle' || status == 'offering')
            Positioned(
              top: 54,
              left: 20,
              right: 20,
              child: _buildTopConsole(theme, isOnline),
            ),

          // 4. Switching portal button (passenger mode switch)
          if (status == 'idle')
            Positioned(
              top: 130,
              right: 20,
              child: _buildPassengerTogglePill(),
            ),

          // 5. Driver Interactive Metrics Dashboard & Ride Cards
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildInteractiveConsole(theme),
          ),
        ],
      ),
    );
  }

  // MARK: - Dark Map with surge zones CustomPaint
  Widget _buildDriverMapCanvas() {
    return Container(
      color: const Color(0xFF141424), // Sleek midnight purple base
      child: ClipRect(
        child: CustomPaint(
          painter: _DriverMapPainter(
            pulseValue: _pulseController.value,
            driverOnline: _db.isDriverOnline.value,
            driverStatus: _db.activeDriverStatus.value,
          ),
          child: Container(),
        ),
      ),
    );
  }

  // Navigation Guidance Header
  Widget _buildNavigationHeaderOverlay(ThemeData theme, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E30),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppTheme.accentDark.withAlpha(100), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentDark.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const CustomIconWidget(
              iconName: 'navigation',
              color: AppTheme.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status == 'navigating_pickup' ? 'PICKUP EN ROUTE' : 'TRIP IN PROGRESS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accent,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  status == 'navigating_pickup' 
                      ? 'Head north towards Hatfield Plaza'
                      : 'Proceed 8.2km on Festival St to Union Buildings',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Top Status Bar Console
  Widget _buildTopConsole(ThemeData theme, bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E30).withAlpha(240),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: const CachedNetworkImageProvider(
              'https://img.rocket.new/generatedImages/rocket_gen_img_11add7eb4-1763294437588.png',
            ),
            backgroundColor: Colors.grey[800],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sipho Dlamini',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      '4.92 • Driver Partner',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          // Sliding Switch for Online / Offline
          GestureDetector(
            onTap: () {
              _db.isDriverOnline.value = !_db.isDriverOnline.value;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 90,
              height: 38,
              decoration: BoxDecoration(
                color: isOnline ? AppTheme.accentDark : const Color(0xFF32324A),
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: isOnline ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (isOnline)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        'ONLINE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isOnline ? Icons.check : Icons.power_settings_new_rounded,
                        color: isOnline ? AppTheme.accentDark : Colors.grey[600],
                        size: 16,
                      ),
                    ),
                  ),
                  if (!isOnline)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        'OFFLINE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Switch to Passenger Mode floating capsule
  Widget _buildPassengerTogglePill() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomIconWidget(iconName: 'person', color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              'Switch Passenger Mode',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Interactive Bottom Console containing Dashboard or Ride Acceptance
  Widget _buildInteractiveConsole(ThemeData theme) {
    final status = _db.activeDriverStatus.value;
    switch (status) {
      case 'idle':
        return _buildDriverDashboardPill(theme);
      case 'offering':
        return _buildIncomingJobOfferCard(theme);
      case 'navigating_pickup':
        return _buildNavigationPickupCard(theme);
      case 'on_trip':
        return _buildActiveRideTripCard(theme);
      default:
        return _buildDriverDashboardPill(theme);
    }
  }

  // Offline or Online Idle Dashboard Metrics
  Widget _buildDriverDashboardPill(ThemeData theme) {
    final isOnline = _db.isDriverOnline.value;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF161626), // Premium dark theme surface
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 25,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 18),
            
            // Online status indicator text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isOnline ? AppTheme.accent : Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isOnline ? AppTheme.accent : Colors.red).withAlpha(100),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isOnline ? 'ONLINE: Waiting for nearby riders...' : 'OFFLINE: Switch online to get jobs',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isOnline ? Colors.white : Colors.grey[400],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Metrics Grid
            ValueListenableBuilder(
              valueListenable: _db.driverEarnings,
              builder: (context, earnings, child) {
                return ValueListenableBuilder(
                  valueListenable: _db.driverTripsCount,
                  builder: (context, tripsCount, child) {
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.7,
                      children: [
                        _buildMetricCard(
                          title: "TODAY'S EARNINGS",
                          value: 'R ${earnings.toStringAsFixed(2)}',
                          icon: 'payment',
                          color: AppTheme.accent,
                        ),
                        _buildMetricCard(
                          title: "RIDES DONE",
                          value: '$tripsCount',
                          icon: 'local_taxi',
                          color: Colors.blue,
                        ),
                        _buildMetricCard(
                          title: "ACCEPTANCE RATE",
                          value: '98%',
                          icon: 'trending_up',
                          color: Colors.purple,
                        ),
                        _buildMetricCard(
                          title: "ONLINE HOURS",
                          value: '4.5 hrs',
                          icon: 'access_time',
                          color: Colors.orange,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(12), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[400],
                  letterSpacing: 0.5,
                ),
              ),
              CustomIconWidget(iconName: icon, color: color, size: 16),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Incoming Dispatch Request overlay card
  Widget _buildIncomingJobOfferCard(ThemeData theme) {
    final job = _db.currentActiveJob.value;
    if (job == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF161626),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black, blurRadius: 25, offset: Offset(0, -10)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulse accept outer ring
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentDark.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'INCOMING TRIP REQUEST',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Passenger card
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[800],
                child: const Text('MO', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['passengerName'] ?? 'Marcus Osei-Bonsu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${job['passengerRating'] ?? 4.87} Rating • Cash payment',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Estimated Earnings
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    job['price'] ?? 'R 65.00',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accent,
                    ),
                  ),
                  Text(
                    'EST. PAYOUT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withAlpha(10)),
          const SizedBox(height: 12),
          
          // Pickup & Dropoff timeline
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle_outlined, color: AppTheme.accent, size: 12),
                  Container(width: 1, height: 16, color: Colors.grey[600]),
                  const Icon(Icons.location_on_rounded, color: Colors.red, size: 12),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['pickup'] ?? 'Pretoria Central',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      job['destination'] ?? 'Union Buildings',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Accept & Reject actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _db.cancelActiveJob(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Decline',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _db.acceptActiveJob(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Center(
                        child: Text(
                          'Accept Job ($_incomingCountdown)',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Accepted Job pickup navigation progress card
  Widget _buildNavigationPickupCard(ThemeData theme) {
    final job = _db.currentActiveJob.value;
    if (job == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF161626),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black, blurRadius: 25, offset: Offset(0, -10)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[800],
                child: const Text('MO', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job['passengerName'] ?? 'Marcus Osei-Bonsu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Pickup: Hatfield Plaza, Hatfield',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              
              // Contact icons
              IconButton(
                icon: const Icon(Icons.message_rounded, color: Colors.blue, size: 20),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.call_rounded, color: AppTheme.accent, size: 20),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Action button to start trip once arrived
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _db.startActiveJobTrip(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Arrived & Start Trip',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Active Job progress timeline card
  Widget _buildActiveRideTripCard(ThemeData theme) {
    final job = _db.currentActiveJob.value;
    if (job == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF161626),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black, blurRadius: 25, offset: Offset(0, -10)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRIP TO DESTINATION',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accent,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      job['destination'] ?? 'Union Buildings',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                job['price'] ?? 'R 65.00',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          LinearProgressIndicator(
            value: 0.65,
            backgroundColor: Colors.white.withAlpha(12),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
            borderRadius: BorderRadius.circular(10),
            minHeight: 6,
          ),
          const SizedBox(height: 24),
          
          // Complete Job action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _db.completeActiveJob();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trip Completed! Earnings Sync complete.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Complete Ride & Collect Fare',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: - Dark theme vector painter for surge zones and active navigations
class _DriverMapPainter extends CustomPainter {
  final double pulseValue;
  final bool driverOnline;
  final String driverStatus;

  _DriverMapPainter({
    required this.pulseValue,
    required this.driverOnline,
    required this.driverStatus,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Green Parks (Dark mode styled)
    Paint parkPaint = Paint()
      ..color = const Color(0xFF1E2822)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.35), 80, parkPaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.70), 100, parkPaint);

    // 2. Draw Blue River (Dark mode styled)
    Paint riverPaint = Paint()
      ..color = const Color(0xFF1A2635)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round;
    Path riverPath = Path();
    riverPath.moveTo(-20, size.height * 0.15);
    riverPath.quadraticBezierTo(size.width * 0.45, size.height * 0.22, size.width * 0.65, size.height * 0.55);
    riverPath.quadraticBezierTo(size.width * 0.85, size.height * 0.85, size.width + 20, size.height * 0.95);
    canvas.drawPath(riverPath, riverPaint);

    // 3. Draw Roads (Dark grid roads)
    Paint roadPaint = Paint()
      ..color = const Color(0xFF222238)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14;

    // Horizontal roads
    canvas.drawLine(Offset(0, size.height * 0.28), Offset(size.width, size.height * 0.28), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.50), Offset(size.width, size.height * 0.50), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.78), Offset(size.width, size.height * 0.78), roadPaint);

    // Vertical roads
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.25, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.50, 0), Offset(size.width * 0.50, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.75, size.height), roadPaint);

    // Road markings
    Paint roadMarkingPaint = Paint()
      ..color = const Color(0xFF2A2A48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(0, size.height * 0.28), Offset(size.width, size.height * 0.28), roadMarkingPaint);
    canvas.drawLine(Offset(0, size.height * 0.50), Offset(size.width, size.height * 0.50), roadMarkingPaint);
    canvas.drawLine(Offset(0, size.height * 0.78), Offset(size.width, size.height * 0.78), roadMarkingPaint);
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.25, size.height), roadMarkingPaint);
    canvas.drawLine(Offset(size.width * 0.50, 0), Offset(size.width * 0.50, size.height), roadMarkingPaint);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.75, size.height), roadMarkingPaint);

    // 4. Draw Surge/High-Demand Heatmap Rings (Glowing orange circles)
    if (driverOnline && driverStatus == 'idle') {
      Paint surgePaint1 = Paint()
        ..color = const Color(0xFFFF9F0A).withAlpha((30 * pulseValue).toInt())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.50), 40 + 20 * pulseValue, surgePaint1);

      Paint surgePaint2 = Paint()
        ..color = const Color(0xFFFF9F0A).withAlpha(150)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.50), 10, surgePaint2);

      Paint surgeLabelPaint = Paint()
        ..color = const Color(0xFFFF9F0A).withAlpha(40)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.28), 50, surgeLabelPaint);
    }

    // 5. Draw Navigation path (Glow green route path from driver to job)
    if (driverStatus == 'navigating_pickup' || driverStatus == 'on_trip') {
      Paint routeGlowPaint = Paint()
        ..color = AppTheme.accent.withAlpha(60)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8;

      Paint routePaint = Paint()
        ..color = AppTheme.accent
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4;

      Path routePath = Path();
      if (driverStatus == 'navigating_pickup') {
        // Path from bottom right corner (0.75, 0.78) to passenger pickup in center (0.50, 0.50)
        routePath.moveTo(size.width * 0.75, size.height * 0.78);
        routePath.lineTo(size.width * 0.50, size.height * 0.78);
        routePath.lineTo(size.width * 0.50, size.height * 0.50);
      } else {
        // Path from center pickup (0.50, 0.50) to dropoff at top left (0.25, 0.28)
        routePath.moveTo(size.width * 0.50, size.height * 0.50);
        routePath.lineTo(size.width * 0.25, size.height * 0.50);
        routePath.lineTo(size.width * 0.25, size.height * 0.28);
      }

      canvas.drawPath(routePath, routeGlowPaint);
      canvas.drawPath(routePath, routePaint);

      // Draw destination pin
      Paint pinPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      Offset destLoc = driverStatus == 'navigating_pickup'
          ? Offset(size.width * 0.50, size.height * 0.50)
          : Offset(size.width * 0.25, size.height * 0.28);
      canvas.drawCircle(destLoc, 6, pinPaint);
    }

    // 6. Draw Driver's Car dot (pulsing blue-green)
    if (driverOnline) {
      // Coordinate matches progress status
      Offset carLoc;
      if (driverStatus == 'navigating_pickup') {
        carLoc = Offset(size.width * 0.75, size.height * 0.78);
      } else if (driverStatus == 'on_trip') {
        carLoc = Offset(size.width * 0.50, size.height * 0.50);
      } else {
        // Centered at 0.75, 0.78
        carLoc = Offset(size.width * 0.75, size.height * 0.78);
      }

      // Pulse
      Paint pulsePaint = Paint()
        ..color = AppTheme.accent.withAlpha((100 * (1.0 - pulseValue)).toInt())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(carLoc, 20 * pulseValue, pulsePaint);

      // Solid
      Paint carBorder = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(carLoc, 7, carBorder);

      Paint carFill = Paint()
        ..color = AppTheme.accentDark
        ..style = PaintingStyle.fill;
      canvas.drawCircle(carLoc, 5, carFill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
