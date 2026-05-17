import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../core/services/mock_database_service.dart';

class WalletBalanceHeroWidget extends StatelessWidget {
  const WalletBalanceHeroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final db = MockDatabaseService();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(89),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: CustomIconWidget(
                        iconName: 'wallet',
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'RideWave Wallet',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<double>(
            valueListenable: db.walletBalance,
            builder: (context, balance, child) {
              return Text(
                'R ${balance.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  height: 1.1,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Available balance',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _WalletAction(
                iconName: 'add_circle',
                label: 'Top Up',
                onTap: () {
                  // TODO: Navigate to top-up flow
                },
              ),
              const SizedBox(width: 12),
              _WalletAction(
                iconName: 'swap_horiz',
                label: 'Transfer',
                onTap: () {
                  // TODO: Navigate to transfer flow
                },
              ),
              const SizedBox(width: 12),
              _WalletAction(
                iconName: 'receipt',
                label: 'Receipts',
                onTap: () {
                  // TODO: Navigate to receipts
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  final String iconName;
  final String label;
  final VoidCallback onTap;

  const _WalletAction({
    required this.iconName,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(31),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(51)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(iconName: iconName, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
