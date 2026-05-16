import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class PaymentMethodsListWidget extends StatefulWidget {
  final VoidCallback onAddTap;

  const PaymentMethodsListWidget({super.key, required this.onAddTap});

  @override
  State<PaymentMethodsListWidget> createState() =>
      _PaymentMethodsListWidgetState();
}

class _PaymentMethodsListWidgetState extends State<PaymentMethodsListWidget> {
  // TODO: Replace with Riverpod/Bloc for production state management
  int _selectedIndex = 0;

  static final List<Map<String, dynamic>> _methodMaps = [
    {
      'type': 'wallet',
      'label': 'RideWave Wallet',
      'detail': '\$124.50 balance',
      'icon': 'wallet',
      'iconColor': 0xFF1A1A2E,
      'iconBg': 0xFFE8E8FF,
      'isDefault': true,
    },
    {
      'type': 'card',
      'label': 'Visa •••• 8890',
      'detail': 'Expires 09/27',
      'icon': 'credit_card',
      'iconColor': 0xFF1565C0,
      'iconBg': 0xFFE3F2FD,
      'isDefault': false,
    },
    {
      'type': 'card',
      'label': 'Mastercard •••• 4421',
      'detail': 'Expires 03/26',
      'icon': 'credit_card',
      'iconColor': 0xFFB45309,
      'iconBg': 0xFFFFF3E0,
      'isDefault': false,
    },
    {
      'type': 'cash',
      'label': 'Cash',
      'detail': 'Pay driver directly',
      'icon': 'money',
      'iconColor': 0xFF2D7A4F,
      'iconBg': 0xFFE8F5E9,
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment Methods',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            Text(
              '${_methodMaps.length} methods',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.onSurfaceMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_methodMaps.length, (i) {
          final method = _methodMaps[i];
          final isSelected = _selectedIndex == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Dismissible(
              key: ValueKey('method_$i'),
              direction: method['type'] == 'cash'
                  ? DismissDirection.none
                  : DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppTheme.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const CustomIconWidget(
                  iconName: 'delete',
                  color: AppTheme.error,
                  size: 24,
                ),
              ),
              onDismissed: (_) {
                // TODO: Remove payment method via backend
              },
              child: GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border(
                      left: BorderSide(
                        color: isSelected
                            ? AppTheme.primary
                            : Color(method['iconColor'] as int).withAlpha(102),
                        width: 3,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? AppTheme.primary.withAlpha(26)
                            : Colors.black.withAlpha(10),
                        blurRadius: isSelected ? 20 : 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color(method['iconBg'] as int),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: method['icon'] as String,
                            color: Color(method['iconColor'] as int),
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
                              children: [
                                Text(
                                  method['label'] as String,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                if (method['isDefault'] == true) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Default',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.accentDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              method['detail'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppTheme.onSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Refresh / manage payment method
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryContainer
                                : AppTheme.surfaceVariantLight,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: isSelected ? 'check_circle' : 'refresh',
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.onSurfaceMuted,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: widget.onAddTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.outlineLight, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Center(
                    child: CustomIconWidget(
                      iconName: 'add',
                      color: AppTheme.primary,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Add Payment Method',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
