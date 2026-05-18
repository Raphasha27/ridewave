import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../core/services/mock_database_service.dart';
import './custom_icon_widget.dart';

class DeveloperCheatConsoleWidget extends StatefulWidget {
  const DeveloperCheatConsoleWidget({super.key});

  @override
  State<DeveloperCheatConsoleWidget> createState() => _DeveloperCheatConsoleWidgetState();
}

class _DeveloperCheatConsoleWidgetState extends State<DeveloperCheatConsoleWidget> {
  bool _isExpanded = false;
  final MockDatabaseService _db = MockDatabaseService();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Collapsible Control HUD Panel
        AnimatedPositioned(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          right: _isExpanded ? 16 : -310,
          bottom: 160, // Positioned safely above standard sheets
          child: Container(
            width: 290,
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F1E).withAlpha(240),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF00FFCC).withAlpha(150),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFCC).withAlpha(40),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00FFCC),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SIMULATION HUD',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isExpanded = false),
                            child: const Icon(Icons.close_rounded, color: Colors.white60, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.white.withAlpha(20)),
                      const SizedBox(height: 8),

                      // Trigger Buttons
                      _buildCheatSectionTitle('WALLET ACTIONS'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCheatButton(
                              label: '+ R 50',
                              icon: 'add_circle',
                              onTap: () {
                                _db.walletBalance.value += 50.0;
                                _db.triggerNotification(
                                  'Developer Wallet Injection',
                                  'Successfully injected R 50.00 into SupplyWave Wallet.',
                                  icon: 'account_balance_wallet',
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildCheatButton(
                              label: '- R 50',
                              icon: 'remove_circle',
                              onTap: () {
                                if (_db.walletBalance.value >= 50.0) {
                                  _db.walletBalance.value -= 50.0;
                                  _db.triggerNotification(
                                    'Developer Wallet Deducted',
                                    'Successfully deducted R 50.00 from SupplyWave Wallet.',
                                    icon: 'wallet',
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildCheatSectionTitle('MOCK DISPATCH TRIGGERS'),
                      const SizedBox(height: 6),
                      _buildCheatButton(
                        label: 'Simulate Driver Match',
                        icon: 'local_taxi',
                        onTap: () {
                          if (_db.activeDriverStatus.value == 'idle') {
                            _db.createBooking(
                              destination: 'Hatfield Plaza, Hatfield',
                              rideType: 'wave_go',
                              price: 'R 65.00',
                              eta: '3 mins',
                            );
                            _db.triggerNotification(
                              'Simulated Dispatch Matched',
                              'Toyota CorollaQuest en route to Pretoria Central (ETA 3m).',
                              icon: 'directions_car',
                            );
                          } else {
                            _db.triggerNotification(
                              'Simulation Blocked',
                              'There is already an active job in progress.',
                              icon: 'warning',
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildCheatButton(
                        label: 'Advance Ride Phase',
                        icon: 'skip_next',
                        onTap: () {
                          final status = _db.activeDriverStatus.value;
                          if (status == 'offering') {
                            _db.acceptActiveJob();
                            _db.triggerNotification('Trip Active Update', 'Driver has accepted your request!', icon: 'check_circle');
                          } else if (status == 'navigating_pickup') {
                            _db.startActiveJobTrip();
                            _db.triggerNotification('Trip Active Update', 'Driver has arrived & started your trip!', icon: 'navigation');
                          } else if (status == 'on_trip') {
                            _db.completeActiveJob();
                            _db.triggerNotification('Trip Active Update', 'Trip completed successfully!', icon: 'stars');
                          } else {
                            _db.triggerNotification('No Active Job', 'Start a booking flow to cycle phases.', icon: 'info');
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildCheatSectionTitle('CUSTOM PUSH ALERTS'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCheatButton(
                              label: 'Arrived Alert',
                              icon: 'location_on',
                              onTap: () {
                                _db.triggerNotification(
                                  'Driver Has Arrived!',
                                  'Sipho is outside Pretoria Central. Look for plate GP 42 ND GP.',
                                  icon: 'pin_drop',
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildCheatButton(
                              label: 'Surge Alert',
                              icon: 'trending_up',
                              onTap: () {
                                _db.triggerNotification(
                                  'Extreme Surge Active ⚡',
                                  'Pretoria East showing 1.8x ride demand. Wave Go fares increased.',
                                  icon: 'bolt',
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 2. Floating Dial Button (Glow neon dial)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          right: _isExpanded ? -80 : 16,
          bottom: 160,
          child: GestureDetector(
            onTap: () => setState(() => _isExpanded = true),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F1E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00FFCC),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFCC).withAlpha(80),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Center(
                child: CustomIconWidget(
                  iconName: 'settings',
                  color: Color(0xFF00FFCC),
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheatSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF00FFCC),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildCheatButton({
    required String label,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(iconName: icon, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
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
}
