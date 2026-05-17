import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/status_badge_widget.dart';
import '../../../widgets/empty_state_widget.dart';

import '../../../core/services/mock_database_service.dart';

class TransactionsListWidget extends StatelessWidget {
  const TransactionsListWidget({super.key});

  List<Map<String, dynamic>> _getCombinedTransactions() {
    final db = MockDatabaseService();
    final List<Map<String, dynamic>> txns = [];

    // Map dynamic completed trips
    for (var trip in db.completedTrips.value) {
      String costStr = trip['cost'].toString().replaceAll('R', '').replaceAll(' ', '');
      double amt = double.tryParse(costStr) ?? 0.0;
      txns.add({
        'id': 'TXN-${trip['id'].toString().replaceAll('trip_', '')}',
        'type': 'ride',
        'icon': 'local_taxi',
        'iconColor': 0xFF1A1A2E,
        'iconBg': 0xFFE8E8FF,
        'title': trip['type'] ?? 'RideWave Standard',
        'subtitle': '${trip['pickup']} → ${trip['dropoff']}',
        'amount': -amt,
        'date': trip['date'] ?? 'Just now',
        'status': 'completed',
        'paymentMethod': 'Wallet',
      });
    }

    // Add static non-ride transactions to enrich the list
    txns.add({
      'id': 'TXN-8841',
      'type': 'topup',
      'icon': 'add_circle',
      'iconColor': 0xFF2D7A4F,
      'iconBg': 0xFFE8F5E9,
      'title': 'Wallet Top-Up',
      'subtitle': 'Via Mastercard •••• 4421',
      'amount': 50.00,
      'date': 'Today, 09:05 AM',
      'status': 'completed',
      'paymentMethod': 'Mastercard •••• 4421',
    });

    txns.add({
      'id': 'TXN-8831',
      'type': 'refund',
      'icon': 'refresh',
      'iconColor': 0xFF0284C7,
      'iconBg': 0xFFE0F2FE,
      'title': 'Cancellation Refund',
      'subtitle': 'TXN-8829 refunded to wallet',
      'amount': 12.00,
      'date': 'May 14, 10:30 AM',
      'status': 'completed',
      'paymentMethod': 'Wallet',
    });

    txns.add({
      'id': 'TXN-8815',
      'type': 'topup',
      'icon': 'add_circle',
      'iconColor': 0xFF2D7A4F,
      'iconBg': 0xFFE8F5E9,
      'title': 'Wallet Top-Up',
      'subtitle': 'Via Visa •••• 8890',
      'amount': 100.00,
      'date': 'May 12, 3:00 PM',
      'status': 'completed',
      'paymentMethod': 'Visa •••• 8890',
    });

    return txns;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: MockDatabaseService().completedTrips,
      builder: (context, trips, child) {
        final transactions = _getCombinedTransactions();
        
        if (transactions.isEmpty) {
          return const EmptyStateWidget(
            iconName: 'receipt',
            title: 'No transactions yet',
            description:
                'Your ride receipts and wallet activity will appear here after your first trip.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            final isPositive = (tx['amount'] as double) > 0;
            final isCancelled = tx['status'] == 'cancelled';

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  _showReceiptSheet(context, tx);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border(
                      left: BorderSide(
                        color: isCancelled
                            ? AppTheme.error.withAlpha(128)
                            : isPositive
                            ? AppTheme.accent.withAlpha(128)
                            : AppTheme.primary.withAlpha(77),
                        width: 3,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color(tx['iconBg'] as int),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: tx['icon'] as String,
                            color: Color(tx['iconColor'] as int),
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    tx['title'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  isPositive
                                      ? '+R ${(tx['amount'] as double).toStringAsFixed(2)}'
                                      : '-R ${(tx['amount'] as double).abs().toStringAsFixed(2)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isPositive
                                        ? AppTheme.success
                                        : isCancelled
                                        ? AppTheme.onSurfaceMuted
                                        : AppTheme.primary,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                    decoration: isCancelled
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              tx['subtitle'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppTheme.onSurfaceMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  tx['date'] as String,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppTheme.onSurfaceMuted,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadgeWidget(
                                  label: isCancelled ? 'Cancelled' : 'Completed',
                                  status: isCancelled
                                      ? RideStatus.cancelled
                                      : RideStatus.completed,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReceiptSheet(BuildContext context, Map<String, dynamic> tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.outlineLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Receipt',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tx['id'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ReceiptRow(label: 'Trip', value: tx['title'] as String),
            _ReceiptRow(label: 'Route', value: tx['subtitle'] as String),
            _ReceiptRow(label: 'Date', value: tx['date'] as String),
            _ReceiptRow(label: 'Payment', value: tx['paymentMethod'] as String),
            _ReceiptRow(
              label: 'Status',
              value: (tx['status'] as String).toUpperCase(),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  '\$${(tx['amount'] as double).abs().toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Download/share receipt
                  Navigator.pop(context);
                },
                icon: const CustomIconWidget(
                  iconName: 'download',
                  color: AppTheme.primary,
                  size: 18,
                ),
                label: Text(
                  'Download Receipt',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.onSurfaceMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.primary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
