import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class MockCredentialsWidget extends StatelessWidget {
  final ValueChanged<String> onUse;

  const MockCredentialsWidget({super.key, required this.onUse});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accent.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CustomIconWidget(
                iconName: 'info',
                color: AppTheme.accentDark,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Demo Credentials',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _CredentialRow(
            label: 'Phone',
            value: '5550000001',
            onCopy: () {
              Clipboard.setData(const ClipboardData(text: '5550000001'));
            },
            onUse: () => onUse('5550000001'),
          ),
          const SizedBox(height: 6),
          _CredentialRow(
            label: 'OTP',
            value: '123456',
            onCopy: () {
              Clipboard.setData(const ClipboardData(text: '123456'));
            },
            onUse: null,
          ),
        ],
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;
  final VoidCallback? onUse;

  const _CredentialRow({
    required this.label,
    required this.value,
    required this.onCopy,
    this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.accentDark,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
              letterSpacing: 1,
            ),
          ),
        ),
        GestureDetector(
          onTap: onCopy,
          child: const CustomIconWidget(
            iconName: 'copy',
            color: AppTheme.accentDark,
            size: 16,
          ),
        ),
        if (onUse != null) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onUse,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Use',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
