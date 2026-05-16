import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class AuthTermsWidget extends StatelessWidget {
  const AuthTermsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: AppTheme.onSurfaceMuted,
          height: 1.5,
        ),
        children: [
          const TextSpan(text: 'By continuing, you agree to RideWave\'s '),
          TextSpan(
            text: 'Terms of Service',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // TODO: Open terms of service
              },
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // TODO: Open privacy policy
              },
          ),
        ],
      ),
    );
  }
}
