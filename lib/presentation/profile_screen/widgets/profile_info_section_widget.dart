import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProfileInfoSectionWidget extends StatefulWidget {
  final Map<String, dynamic> riderData;
  final bool isEditing;
  final VoidCallback onEditToggle;

  const ProfileInfoSectionWidget({
    super.key,
    required this.riderData,
    required this.isEditing,
    required this.onEditToggle,
  });

  @override
  State<ProfileInfoSectionWidget> createState() =>
      _ProfileInfoSectionWidgetState();
}

class _ProfileInfoSectionWidgetState extends State<ProfileInfoSectionWidget> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.riderData['name']);
    _emailController = TextEditingController(text: widget.riderData['email']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(color: AppTheme.primary.withAlpha(153), width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personal Info',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onEditToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isEditing
                          ? AppTheme.accent
                          : AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: widget.isEditing ? 'check' : 'edit',
                          color: widget.isEditing
                              ? Colors.white
                              : AppTheme.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.isEditing ? 'Save' : 'Edit',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.isEditing
                                ? Colors.white
                                : AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppTheme.outlineVariantLight, height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _InfoRow(
                  iconName: 'person',
                  iconColor: AppTheme.primary,
                  iconBg: AppTheme.primaryContainer,
                  label: 'Full Name',
                  value: widget.riderData['name'],
                  isEditing: widget.isEditing,
                  controller: _nameController,
                ),
                const SizedBox(height: 14),
                _InfoRow(
                  iconName: 'phone',
                  iconColor: AppTheme.accent,
                  iconBg: AppTheme.accentContainer,
                  label: 'Phone',
                  value: widget.riderData['phone'],
                  isEditing: false,
                  controller: TextEditingController(
                    text: widget.riderData['phone'],
                  ),
                ),
                const SizedBox(height: 14),
                _InfoRow(
                  iconName: 'email',
                  iconColor: const Color(0xFF7C3AED),
                  iconBg: const Color(0xFFF3E8FF),
                  label: 'Email',
                  value: widget.riderData['email'],
                  isEditing: widget.isEditing,
                  controller: _emailController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String iconName;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final bool isEditing;
  final TextEditingController controller;

  const _InfoRow({
    required this.iconName,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.isEditing,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: iconName,
              color: iconColor,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppTheme.onSurfaceMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              isEditing
                  ? TextField(
                      controller: controller,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 0,
                        ),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primary),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.outlineLight),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primary,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
