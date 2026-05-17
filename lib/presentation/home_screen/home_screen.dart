import 'dart:async';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_export.dart';
import '../../widgets/app_navigation.dart';
import '../../core/services/mock_database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final int _navIndex = 0;
  
  // Navigation & Flow State
  // 0 = Map default view
  // 1 = Destination Selection Sheet
  // 2 = Ride Type Selection Sheet
  // 3 = Searching/Dispatching Radar Screen
  // 4 = Driver Matched/Arriving Screen
  int _appState = 0; 

  String _destination = '';
  String _selectedRideType = 'wave_go';
  
  // Simulated Map Markers & Drivers
  late List<Point<double>> _driverPositions;
  late AnimationController _pulseController;
  late AnimationController _driverMovementController;
  
  // Dispatch Animation
  late AnimationController _radarController;
  Timer? _dispatchTimer;
  
  // Matched Driver Details
  final Map<String, dynamic> _matchedDriver = {
    'name': 'Sipho Dlamini',
    'rating': 4.92,
    'trips': '1,240',
    'car': 'White Toyota Corolla',
    'plate': 'GP 42 ND GP',
    'phone': '+27 78 117 2470',
    'avatarUrl': 'https://img.rocket.new/generatedImages/rocket_gen_img_11add7eb4-1763294437588.png',
  };

  @override
  void initState() {
    super.initState();
    
    // Set up mock driver positions around passenger (centered at 0.5, 0.5)
    _driverPositions = [
      const Point(0.32, 0.45),
      const Point(0.68, 0.28),
      const Point(0.55, 0.72),
      const Point(0.25, 0.62),
    ];

    // Pulsing circle animation for passenger dot
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Subtle drift movement for mock drivers
    _driverMovementController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..addListener(() {
        setState(() {
          double val = _driverMovementController.value * 2 * pi;
          _driverPositions[0] = Point(0.32 + 0.04 * sin(val), 0.45 + 0.02 * cos(val));
          _driverPositions[1] = Point(0.68 + 0.02 * cos(val * 1.5), 0.28 + 0.03 * sin(val * 1.5));
          _driverPositions[2] = Point(0.55 + 0.03 * sin(val * 0.8), 0.72 + 0.04 * cos(val * 0.8));
          _driverPositions[3] = Point(0.25 + 0.02 * cos(val), 0.62 + 0.03 * sin(val));
        });
      });
    _driverMovementController.repeat();

    // Radar screen for searching state
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _driverMovementController.dispose();
    _radarController.dispose();
    _dispatchTimer?.cancel();
    super.dispose();
  }

  void _startBookingDispatch() {
    setState(() {
      _appState = 3; // Switching to Dispatching Radar
    });
    _radarController.repeat();
    
    // Register the job request in the shared MockDatabaseService!
    MockDatabaseService().createBooking(
      destination: _destination.isNotEmpty ? _destination : 'Union Buildings, Arcadia',
      rideType: _selectedRideType,
      price: _selectedRideType == 'wave_go' 
          ? 'R 65.00' 
          : (_selectedRideType == 'wave_premium' ? 'R 115.00' : 'R 160.00'),
      eta: _selectedRideType == 'wave_go' 
          ? '3 mins' 
          : (_selectedRideType == 'wave_premium' ? '2 mins' : '5 mins'),
    );
    
    _dispatchTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _appState = 4; // Matched Driver found!
        });
        _radarController.stop();
      }
    });
  }

  void _resetFlow() {
    setState(() {
      _appState = 0;
      _destination = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // 1. Vector Map Interactive Canvas
          Positioned.fill(
            child: _buildMapCanvas(context),
          ),

          // 2. Translucent Search Panel (Top Floating Card)
          if (_appState == 0 || _appState == 1)
            Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: _buildTopSearchCard(theme),
            ),

          // 3. Floating Quick Action Buttons (GPS & Menu)
          if (_appState == 0 || _appState == 2)
            Positioned(
              bottom: _appState == 0 ? 180 : 360,
              right: 20,
              child: _buildFloatingActions(theme),
            ),

          // 4. Slide-Up Interactive Bottom Sheets based on App State
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildInteractiveSheet(theme, isTablet),
          ),
        ],
      ),
      bottomNavigationBar: _appState <= 1 
        ? SafeArea(
            child: AppNavigation(
              currentIndex: _navIndex,
              onTap: (i) {
                if (i == 1) Navigator.pushReplacementNamed(context, AppRoutes.tripsScreen);
                if (i == 2) Navigator.pushReplacementNamed(context, AppRoutes.paymentsScreen);
                if (i == 3) Navigator.pushReplacementNamed(context, AppRoutes.profileScreen);
              },
            ),
          )
        : null, // Hide navigation bar during booking flow for immersion
    );
  }

  // MARK: - Map Canvas widget using CustomPainter
  Widget _buildMapCanvas(BuildContext context) {
    return Container(
      color: const Color(0xFFEBF0F5), // Light Map ground base
      child: ClipRect(
        child: CustomPaint(
          painter: _MapGridPainter(
            pulseValue: _pulseController.value,
            driverPositions: _driverPositions,
          ),
          child: Container(),
        ),
      ),
    );
  }

  // MARK: - Floating Top Search Bar
  Widget _buildTopSearchCard(ThemeData theme) {
    return SafeArea(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(240),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const CustomIconWidget(
                iconName: 'local_taxi',
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pickup Point',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                  Text(
                    'Current Location (Pretoria Central)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 24,
              width: 1,
              color: AppTheme.outlineLight,
            ),
            IconButton(
              icon: const CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.primary,
                size: 20,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Floating Map Buttons (Recenter)
  Widget _buildFloatingActions(ThemeData theme) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recentered map to GPS location')),
            );
          },
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: CustomIconWidget(
                iconName: 'my_location',
                color: AppTheme.primary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // MARK: - Slide-Up Sheets
  Widget _buildInteractiveSheet(ThemeData theme, bool isTablet) {
    switch (_appState) {
      case 0:
        return _buildDefaultPanel(theme, isTablet);
      case 1:
        return _buildDestinationSheet(theme, isTablet);
      case 2:
        return _buildRideSelectionSheet(theme, isTablet);
      case 3:
        return _buildRadarScreen(theme, isTablet);
      case 4:
        return _buildDriverMatchedCard(theme, isTablet);
      default:
        return _buildDefaultPanel(theme, isTablet);
    }
  }

  // State 0: Default Welcome Panel
  Widget _buildDefaultPanel(ThemeData theme, bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.outlineLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Where to today, Marcus? 👋',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Where To Button
          GestureDetector(
            onTap: () => setState(() => _appState = 1),
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.outlineLight.withAlpha(128)),
              ),
              child: Row(
                children: [
                  const CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Search destination...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      color: AppTheme.onSurfaceMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Quick Saved Places
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSavedPlaceItem(
                theme: theme,
                icon: 'home',
                title: 'Home',
                subtitle: 'Pretoria East',
                onTap: () {
                  setState(() {
                    _destination = 'Home (Pretoria East)';
                    _appState = 2; // Jump straight to ride selection
                  });
                },
              ),
              _buildSavedPlaceItem(
                theme: theme,
                icon: 'work',
                title: 'Work',
                subtitle: 'Hatfield Office',
                onTap: () {
                  setState(() {
                    _destination = 'Work (Hatfield Office)';
                    _appState = 2;
                  });
                },
              ),
              _buildSavedPlaceItem(
                theme: theme,
                icon: 'explore',
                title: 'Menlyn',
                subtitle: 'Menlyn Mall',
                onTap: () {
                  setState(() {
                    _destination = 'Menlyn Mall';
                    _appState = 2;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPlaceItem({
    required ThemeData theme,
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 104,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight.withAlpha(180),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariantLight),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: AppTheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: AppTheme.onSurfaceMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // State 1: Destination Selection Search Sheet
  Widget _buildDestinationSheet(ThemeData theme, bool isTablet) {
    final List<String> suggestions = [
      'Menlyn Mall, Pretoria',
      'Union Buildings, Arcadia',
      'University of Pretoria, Hatfield',
      'Centurion Mall, Centurion',
      'Brooklyn Mall, Brooklyn',
      'National Zoological Garden, Pretoria'
    ];

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.outlineLight,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          
          // Header search row
          Row(
            children: [
              IconButton(
                icon: const CustomIconWidget(
                  iconName: 'arrow_back',
                  color: AppTheme.primary,
                  size: 22,
                ),
                onPressed: () => setState(() => _appState = 0),
              ),
              Expanded(
                child: Text(
                  'Set Your Destination',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Destination Input field
          TextField(
            autofocus: true,
            onChanged: (val) {
              setState(() {
                _destination = val;
              });
            },
            decoration: InputDecoration(
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: CustomIconWidget(
                  iconName: 'location_on',
                  color: AppTheme.error,
                  size: 20,
                ),
              ),
              hintText: 'Enter dropoff address...',
              suffixIcon: _destination.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => setState(() => _destination = ''),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          
          // Suggestions list
          Expanded(
            child: ListView.separated(
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => Divider(color: AppTheme.outlineVariantLight, height: 1),
              itemBuilder: (context, index) {
                final place = suggestions[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      shape: BoxShape.circle,
                    ),
                    child: const CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.primary,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    place,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  subtitle: Text(
                    'Pretoria, South Africa',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _destination = place;
                      _appState = 2; // Transition to Ride Selection
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // State 2: Ride Selection Bottom Sheet
  Widget _buildRideSelectionSheet(ThemeData theme, bool isTablet) {
    final List<Map<String, dynamic>> rides = [
      {
        'id': 'wave_go',
        'name': 'Wave Go',
        'desc': 'Economical everyday trips',
        'price': 'R 65.00',
        'eta': '3 mins',
        'icon': 'local_taxi',
        'color': AppTheme.accent,
      },
      {
        'id': 'wave_premium',
        'name': 'Wave Premium',
        'desc': 'Sleek luxury sedan comfort',
        'price': 'R 115.00',
        'eta': '2 mins',
        'icon': 'local_taxi',
        'color': AppTheme.primary,
      },
      {
        'id': 'wave_xl',
        'name': 'Wave XL',
        'desc': 'Roomy SUVs for group rides',
        'price': 'R 160.00',
        'eta': '5 mins',
        'icon': 'airport_shuttle',
        'color': const Color(0xFFF59E0B),
      },
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.outlineLight,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          
          // Destination Info Header
          Row(
            children: [
              IconButton(
                icon: const CustomIconWidget(
                  iconName: 'arrow_back',
                  color: AppTheme.primary,
                  size: 22,
                ),
                onPressed: () => setState(() => _appState = 1),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip to:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.onSurfaceMuted,
                      ),
                    ),
                    Text(
                      _destination,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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
          const SizedBox(height: 16),
          
          // Ride Selection List
          Column(
            children: rides.map((ride) {
              final isSelected = _selectedRideType == ride['id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedRideType = ride['id'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryContainer.withAlpha(128) : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.outlineLight.withAlpha(150),
                      width: isSelected ? 2 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (ride['color'] as Color).withAlpha(38),
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: ride['icon'] as String,
                          color: ride['color'] as Color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  ride['name'] as String,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.outlineVariantLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    ride['eta'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ride['desc'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.onSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        ride['price'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          
          // Payment Selector & Confirm Button
          Divider(color: AppTheme.outlineVariantLight),
          const SizedBox(height: 12),
          Row(
            children: [
              const CustomIconWidget(
                iconName: 'credit_card',
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Visa •••• 4242',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                'Change',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startBookingDispatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Confirm Booking',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
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

  // State 3: Searching Dispatch Radar Screen
  Widget _buildRadarScreen(ThemeData theme, bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.outlineLight,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          
          // Radar glowing searching circles
          AnimatedBuilder(
            animation: _radarController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: List.generate(3, (index) {
                  double val = (_radarController.value + index / 3) % 1.0;
                  return Container(
                    width: 140 * val,
                    height: 140 * val,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary.withAlpha((50 * (1.0 - val)).toInt()),
                      border: Border.all(
                        color: AppTheme.primary.withAlpha((120 * (1.0 - val)).toInt()),
                        width: 1.5,
                      ),
                    ),
                  );
                })..add(
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withAlpha(80),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: CustomIconWidget(
                        iconName: 'local_taxi',
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  )
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          Text(
            'Finding Your RideWave...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Contacting drivers nearby Pretoria Central',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppTheme.onSurfaceMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Cancel dispatch button
          OutlinedButton(
            onPressed: _resetFlow,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Cancel Search',
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // State 4: Driver Matched Screen
  Widget _buildDriverMatchedCard(ThemeData theme, bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.outlineLight,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          
          // Success matched title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppTheme.accentDark, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'RIDE SECURED',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Driver Arriving in 3 mins',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Driver Profile section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight.withAlpha(128),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      backgroundImage: CachedNetworkImageProvider(_matchedDriver['avatarUrl'] as String),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _matchedDriver['name'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.orange, size: 15),
                              const SizedBox(width: 2),
                              Text(
                                '${_matchedDriver['rating']} • ${_matchedDriver['trips']} trips',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.onSurfaceMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Vehicle Info Block
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _matchedDriver['plate'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          _matchedDriver['car'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppTheme.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Action Buttons: Call, Message, Cancel
          Row(
            children: [
              Expanded(
                child: _buildDriverActionButton(
                  icon: 'message',
                  label: 'Message',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chat window opened with Sipho')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDriverActionButton(
                  icon: 'call',
                  label: 'Call',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Dialing Sipho at ${_matchedDriver['phone']}')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDriverActionButton(
                  icon: 'cancel',
                  label: 'Cancel',
                  isDestructive: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ride booking cancelled successfully')),
                    );
                    _resetFlow();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverActionButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDestructive ? AppTheme.errorContainer : AppTheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isDestructive ? AppTheme.error : AppTheme.primary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDestructive ? AppTheme.error : AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - CustomPainter for styled map grids, roads, parks and cars
class _MapGridPainter extends CustomPainter {
  final double pulseValue;
  final List<Point<double>> driverPositions;

  _MapGridPainter({
    required this.pulseValue,
    required this.driverPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Green Parks
    Paint parkPaint = Paint()
      ..color = const Color(0xFFD8ECD0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.35), 80, parkPaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.70), 100, parkPaint);

    // 2. Draw Blue River
    Paint riverPaint = Paint()
      ..color = const Color(0xFFC0E0F8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round;
    Path riverPath = Path();
    riverPath.moveTo(-20, size.height * 0.15);
    riverPath.quadraticBezierTo(size.width * 0.45, size.height * 0.22, size.width * 0.65, size.height * 0.55);
    riverPath.quadraticBezierTo(size.width * 0.85, size.height * 0.85, size.width + 20, size.height * 0.95);
    canvas.drawPath(riverPath, riverPaint);

    // 3. Draw Roads (Grey grid lines representing blocks)
    Paint roadPaint = Paint()
      ..color = Colors.white
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

    // Draw inner road markings (Dotted lines inside roads)
    Paint roadMarkingPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Draw centerlines
    canvas.drawLine(Offset(0, size.height * 0.28), Offset(size.width, size.height * 0.28), roadMarkingPaint);
    canvas.drawLine(Offset(0, size.height * 0.50), Offset(size.width, size.height * 0.50), roadMarkingPaint);
    canvas.drawLine(Offset(0, size.height * 0.78), Offset(size.width, size.height * 0.78), roadMarkingPaint);
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.25, size.height), roadMarkingPaint);
    canvas.drawLine(Offset(size.width * 0.50, 0), Offset(size.width * 0.50, size.height), roadMarkingPaint);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.75, size.height), roadMarkingPaint);

    // 4. Draw Pulsing Passenger Dot (Center at 0.50, 0.50 - center road intersection)
    Offset passengerLoc = Offset(size.width * 0.50, size.height * 0.50);
    
    // Pulse ring
    Paint pulseRingPaint = Paint()
      ..color = AppTheme.primary.withAlpha((80 * (1.0 - pulseValue)).toInt())
      ..style = PaintingStyle.fill;
    canvas.drawCircle(passengerLoc, 24 * pulseValue, pulseRingPaint);

    // Solid base ring
    Paint passengerBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(passengerLoc, 8, passengerBorder);

    Paint passengerDot = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(passengerLoc, 6, passengerDot);

    // 5. Draw Nearby Driver Cars (Yellow/Blue cars)
    for (var pos in driverPositions) {
      Offset driverLoc = Offset(size.width * pos.x, size.height * pos.y);
      
      // Draw circular background pill for the driver
      Paint driverBG = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..shadowColor = Colors.black.withAlpha(60);
      canvas.drawCircle(driverLoc, 13, driverBG);

      Paint driverBorder = Paint()
        ..color = AppTheme.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(driverLoc, 13, driverBorder);

      // Simple representational dot/triangle for taxi orientation
      Paint carPaint = Paint()
        ..color = AppTheme.primary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(driverLoc, 6, carPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
