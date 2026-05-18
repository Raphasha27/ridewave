import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import './custom_icon_widget.dart';

class InAppNotificationBannerWidget extends StatefulWidget {
  final String title;
  final String body;
  final String iconName;
  final VoidCallback onClose;

  const InAppNotificationBannerWidget({
    super.key,
    required this.title,
    required this.body,
    required this.iconName,
    required this.onClose,
  });

  @override
  State<InAppNotificationBannerWidget> createState() => _InAppNotificationBannerWidgetState();
}

class _InAppNotificationBannerWidgetState extends State<InAppNotificationBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E34).withAlpha(225),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.accent.withAlpha(80),
                    width: 1.5,
                  ),
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
                    // Icon circle
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: widget.iconName,
                        color: AppTheme.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Texts
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.body,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Close button
                    GestureDetector(
                      onTap: () {
                        _slideController.reverse().then((_) {
                          widget.onClose();
                        });
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white60,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
