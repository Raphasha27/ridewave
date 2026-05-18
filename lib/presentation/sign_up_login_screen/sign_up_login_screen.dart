import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import './widgets/auth_blob_animation_widget.dart';
import './widgets/auth_terms_widget.dart';
import './widgets/mock_credentials_widget.dart';
import './widgets/otp_input_widget.dart';
import './widgets/phone_input_widget.dart';

// TODO: Replace with Riverpod/Bloc for production state management
class SignUpLoginScreen extends StatefulWidget {
  const SignUpLoginScreen({super.key});

  @override
  State<SignUpLoginScreen> createState() => _SignUpLoginScreenState();
}

class _SignUpLoginScreenState extends State<SignUpLoginScreen>
    with TickerProviderStateMixin {
  int _step = 0; // 0 = phone, 1 = otp
  bool _isLoading = false;
  String _phoneNumber = '';
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _goToOtp() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _phoneNumber = _phoneController.text.trim();
      _isLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _step = 1;
      });
      _slideController.reset();
      _slideController.forward();
    });
  }

  void _verifyOtp() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 6-digit code')),
      );
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // TODO: Validate OTP with backend auth service
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.homeScreen,
        (route) => false,
      );
    });
  }

  void _autofillCredentials(String phone) {
    _phoneController.text = phone;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: isTablet
            ? _buildTabletLayout(context, theme, size)
            : _buildPhoneLayout(context, theme, size),
      ),
    );
  }

  Widget _buildPhoneLayout(BuildContext context, ThemeData theme, Size size) {
    return Stack(
      children: [
        // Blob animation background
        const AuthBlobAnimationWidget(),
        // Scrollable content
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.08),
              _buildLogoSection(theme),
              SizedBox(height: size.height * 0.05),
              _buildStepContent(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, ThemeData theme, Size size) {
    return Stack(
      children: [
        const AuthBlobAnimationWidget(),
        Center(
          child: Container(
            width: 480,
            margin: const EdgeInsets.symmetric(vertical: 40),
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight.withAlpha(242),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withAlpha(31),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogoSection(theme),
                  const SizedBox(height: 32),
                  _buildStepContent(theme),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CustomIconWidget(
                  iconName: 'local_taxi',
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'SupplyWave',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _step == 0
              ? Column(
                  key: const ValueKey('title_0'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter your phone number to get started',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.onSurfaceMuted,
                      ),
                    ),
                  ],
                )
              : Column(
                  key: const ValueKey('title_1'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verify your number',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter the 6-digit code sent to\n+1 $_phoneNumber',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.onSurfaceMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _step == 0 ? _buildPhoneStep(theme) : _buildOtpStep(theme),
        ),
      ),
    );
  }

  Widget _buildPhoneStep(ThemeData theme) {
    return Column(
      key: const ValueKey('step_phone'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          key: _formKey,
          child: PhoneInputWidget(
            controller: _phoneController,
            onChanged: (val) => setState(() {}),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: _buildPrimaryButton(
            label: 'Send OTP',
            icon: 'arrow_forward',
            onTap: _goToOtp,
            isLoading: _isLoading,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: AppTheme.outlineLight)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or continue with',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppTheme.onSurfaceMuted,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppTheme.outlineLight)),
          ],
        ),
        const SizedBox(height: 16),
        _buildSocialButton(
          icon: 'account_circle',
          label: 'Continue with Google',
          onTap: () {
            // TODO: Implement Google Sign-In
          },
        ),
        const SizedBox(height: 20),
        const AuthTermsWidget(),
        const SizedBox(height: 24),
        MockCredentialsWidget(onUse: _autofillCredentials),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildOtpStep(ThemeData theme) {
    return Column(
      key: const ValueKey('step_otp'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OtpInputWidget(
          controllers: _otpControllers,
          focusNodes: _otpFocusNodes,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Didn't receive the code?",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.onSurfaceMuted,
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: Resend OTP via backend
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('OTP resent successfully')),
                );
              },
              child: Text(
                'Resend',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: _buildPrimaryButton(
            label: 'Verify & Continue',
            icon: 'check',
            onTap: _verifyOtp,
            isLoading: _isLoading,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() => _step = 0);
              _slideController.reset();
              _slideController.forward();
            },
            child: Text(
              '← Change phone number',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required String icon,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 54,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withAlpha(77),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CustomIconWidget(
                      iconName: icon,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.outlineLight, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(iconName: icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
