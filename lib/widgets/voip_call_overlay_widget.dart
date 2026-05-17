import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import './custom_icon_widget.dart';

class VoipCallOverlayWidget extends StatefulWidget {
  final String contactName;
  final String contactAvatarUrl;
  final String contactRole;
  final VoidCallback onHangUp;

  const VoipCallOverlayWidget({
    super.key,
    required this.contactName,
    required this.contactAvatarUrl,
    required this.contactRole,
    required this.onHangUp,
  });

  @override
  State<VoipCallOverlayWidget> createState() => _VoipCallOverlayWidgetState();
}

class _VoipCallOverlayWidgetState extends State<VoipCallOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _statusTimer;
  Timer? _secondsTimer;

  String _callStatus = 'Calling...';
  int _secondsElapsed = 0;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isVideoOn = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Connection flow simulation
    _statusTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _callStatus = 'Ringing...';
        });
      }
      _statusTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _callStatus = 'Connected';
          });
          // Start the call clock
          _startCallClock();
        }
      });
    });
  }

  void _startCallClock() {
    _secondsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _statusTimer?.cancel();
    _secondsTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 1. Frosted Glass Backdrop Filter
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: const Color(0xFF0F0F1A).withAlpha(220),
              ),
            ),
          ),

          // 2. Main Call Console Content
          Positioned.fill(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Section: App branding & Encryption lock
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CustomIconWidget(
                              iconName: 'lock',
                              color: AppTheme.accent,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'End-to-End Encrypted VoIP',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.white60,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Middle Section: Pulsing waves & Avatar
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ripple 1
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              double scale = 1.0 + (_pulseController.value * 0.8);
                              double opacity = 1.0 - _pulseController.value;
                              return Container(
                                width: 140 * scale,
                                height: 140 * scale,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.accent.withAlpha((opacity * 100).toInt()),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Ripple 2
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              double val = (_pulseController.value + 0.5) % 1.0;
                              double scale = 1.0 + (val * 0.8);
                              double opacity = 1.0 - val;
                              return Container(
                                width: 140 * scale,
                                height: 140 * scale,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primaryLight.withAlpha((opacity * 100).toInt()),
                                    width: 1.5,
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          // Circular avatar photo
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(50),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage(widget.contactAvatarUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Contact info
                      Text(
                        widget.contactName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.contactRole.toUpperCase()} • $runStatus',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _callStatus == 'Connected' ? AppTheme.accent : Colors.white60,
                        ),
                      ),
                    ],
                  ),

                  // Bottom Section: Toggles & Hang up trigger
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48, left: 24, right: 24),
                    child: Column(
                      children: [
                        // Console Option Toggles (Mute, Speaker, Video)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildConsoleButton(
                              icon: 'mic_off',
                              isActive: _isMuted,
                              label: 'Mute',
                              onTap: () {
                                setState(() {
                                  _isMuted = !_isMuted;
                                });
                              },
                            ),
                            _buildConsoleButton(
                              icon: 'volume_up',
                              isActive: _isSpeakerOn,
                              label: 'Speaker',
                              onTap: () {
                                setState(() {
                                  _isSpeakerOn = !_isSpeakerOn;
                                });
                              },
                            ),
                            _buildConsoleButton(
                              icon: 'videocam_off',
                              isActive: _isVideoOn,
                              label: 'Video',
                              onTap: () {
                                setState(() {
                                  _isVideoOn = !_isVideoOn;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),

                        // Red Hang Up Button
                        GestureDetector(
                          onTap: widget.onHangUp,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppTheme.error,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.error.withAlpha(100),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: CustomIconWidget(
                                iconName: 'call_end',
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  String get runStatus {
    if (_callStatus == 'Connected') {
      return _formatDuration(_secondsElapsed);
    }
    return _callStatus;
  }

  Widget _buildConsoleButton({
    required String icon,
    required bool isActive,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? Colors.white : Colors.white24,
                width: 1.5,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: isActive ? const Color(0xFF0F0F1A) : Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
