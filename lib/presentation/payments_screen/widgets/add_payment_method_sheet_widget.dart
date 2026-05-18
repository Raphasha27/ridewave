import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class AddPaymentMethodSheetWidget extends StatefulWidget {
  const AddPaymentMethodSheetWidget({super.key});

  @override
  State<AddPaymentMethodSheetWidget> createState() =>
      _AddPaymentMethodSheetWidgetState();
}

class _AddPaymentMethodSheetWidgetState
    extends State<AddPaymentMethodSheetWidget> with TickerProviderStateMixin {
  // TODO: Replace with Riverpod/Bloc for production state management
  int _selectedType = 0; // 0=card, 1=wallet topup
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _obscureCvv = true;

  // Scanner Simulator properties
  bool _isScanning = false;
  late AnimationController _scannerLaserController;

  @override
  void initState() {
    super.initState();
    _scannerLaserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  void _startMockScan() {
    _scannerLaserController.repeat(reverse: true);
    
    // Automatically complete mock scan after 2.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _cardNumberController.text = '5412 7599 2470 1180';
          _cardNameController.text = 'Marcus Osei-Bonsu';
          _expiryController.text = '09/29';
          _cvvController.text = '382';
          _isScanning = false;
        });
        _scannerLaserController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text('Card scanned successfully! Autofilled details.'),
              ],
            ),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _scannerLaserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: 520, // Fixed height to allow clean Scanner overlay mapping
        decoration: const BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
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
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Add Payment Method',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Type selector
                  Row(
                    children: [
                      _TypeChip(
                        label: 'Credit / Debit Card',
                        iconName: 'credit_card',
                        isSelected: _selectedType == 0,
                        onTap: () => setState(() => _selectedType = 0),
                      ),
                      const SizedBox(width: 10),
                      _TypeChip(
                        label: 'Top Up Wallet',
                        iconName: 'wallet',
                        isSelected: _selectedType == 1,
                        onTap: () => setState(() => _selectedType = 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_selectedType == 0) _buildCardForm() else _buildTopUpForm(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _isLoading ? null : _submit,
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
                          child: _isLoading
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
                                    const CustomIconWidget(
                                      iconName: 'add',
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _selectedType == 0
                                          ? 'Add Card'
                                          : 'Top Up Wallet',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            if (_isScanning) _buildScannerOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Container(
          color: const Color(0xFF0F0F1E).withAlpha(245),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CREDIT CARD SCANNER',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF00FFCC),
                        letterSpacing: 1.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isScanning = false;
                        });
                        _scannerLaserController.stop();
                      },
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              
              // Viewfinder Rect
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 280,
                    height: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white38, width: 2.5),
                    ),
                  ),
                  // Glowing Neon Green Laser Line
                  AnimatedBuilder(
                    animation: _scannerLaserController,
                    builder: (context, child) {
                      double topOffset = _scannerLaserController.value * 150;
                      return Positioned(
                        top: 10 + topOffset,
                        child: Container(
                          width: 260,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00FFCC),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FFCC).withAlpha(200),
                                blurRadius: 10,
                                spreadRadius: 1.5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Hold card within frame to scan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _PremiumField(
            controller: _cardNumberController,
            label: 'Card Number',
            hint: '•••• •••• •••• ••••',
            iconName: 'credit_card',
            keyboardType: TextInputType.number,
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _isScanning = true;
                });
                _startMockScan();
              },
              child: const CustomIconWidget(
                iconName: 'photo_camera',
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            validator: (v) {
              if (v == null || v.isEmpty) return 'Card number is required';
              if (v.replaceAll(' ', '').length < 16) {
                return 'Enter valid 16-digit card number';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _PremiumField(
            controller: _cardNameController,
            label: 'Cardholder Name',
            hint: 'Name as on card',
            iconName: 'person',
            keyboardType: TextInputType.name,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Cardholder name is required';
              return null;
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PremiumField(
                  controller: _expiryController,
                  label: 'Expiry Date',
                  hint: 'MM/YY',
                  iconName: 'calendar_today',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryFormatter(),
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 5) return 'Invalid';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PremiumField(
                  controller: _cvvController,
                  label: 'CVV',
                  hint: '•••',
                  iconName: 'lock',
                  keyboardType: TextInputType.number,
                  obscureText: _obscureCvv,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscureCvv = !_obscureCvv),
                    child: CustomIconWidget(
                      iconName: _obscureCvv ? 'visibility' : 'visibility_off',
                      color: AppTheme.onSurfaceMuted,
                      size: 18,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 3) return 'Invalid CVV';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpForm() {
    final amounts = ['\$10', '\$25', '\$50', '\$100', '\$200'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Amount',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: amounts.map((amt) {
            return GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.outlineLight),
                ),
                child: Text(
                  amt,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text(
          'Current balance: \$124.50',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppTheme.onSurfaceMuted,
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (_selectedType == 0) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pop(context);
      // TODO: Add payment method via backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedType == 0
                ? 'Card added successfully'
                : 'Wallet topped up successfully',
          ),
          backgroundColor: AppTheme.success,
        ),
      );
    });
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String iconName;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.iconName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryContainer
              : AppTheme.surfaceVariantLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.outlineLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isSelected ? AppTheme.primary : AppTheme.onSurfaceMuted,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.primary : AppTheme.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String iconName;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;

  const _PremiumField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.iconName,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isFocused ? AppTheme.primary : AppTheme.outlineLight,
              width: _isFocused ? 2 : 1.5,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            obscureText: widget.obscureText,
            validator: widget.validator,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.primary,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.onSurfaceMuted,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CustomIconWidget(
                  iconName: widget.iconName,
                  color: _isFocused
                      ? AppTheme.primary
                      : AppTheme.onSurfaceMuted,
                  size: 18,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 44),
              suffixIcon: widget.suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: widget.suffixIcon,
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(minWidth: 44),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 4,
              ),
              errorStyle: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppTheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
