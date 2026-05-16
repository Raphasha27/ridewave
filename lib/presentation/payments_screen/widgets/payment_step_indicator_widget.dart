import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

enum PaymentStep { unlock, detailing, complete }

class PaymentStepIndicatorWidget extends StatelessWidget {
  final PaymentStep currentStep;

  const PaymentStepIndicatorWidget({
    super.key,
    this.currentStep = PaymentStep.detailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _StepDot(label: 'Requested', state: _stepState(0)),
          _StepConnector(isDone: _stepIndex() >= 1),
          _StepDot(label: 'In Progress', state: _stepState(1)),
          _StepConnector(isDone: _stepIndex() >= 2),
          _StepDot(label: 'Completed', state: _stepState(2)),
        ],
      ),
    );
  }

  int _stepIndex() {
    switch (currentStep) {
      case PaymentStep.unlock:
        return 0;
      case PaymentStep.detailing:
        return 1;
      case PaymentStep.complete:
        return 2;
    }
  }

  _DotState _stepState(int index) {
    final current = _stepIndex();
    if (index < current) return _DotState.done;
    if (index == current) return _DotState.active;
    return _DotState.pending;
  }
}

enum _DotState { done, active, pending }

class _StepDot extends StatelessWidget {
  final String label;
  final _DotState state;

  const _StepDot({required this.label, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: state == _DotState.done
                ? AppTheme.accent
                : state == _DotState.active
                ? AppTheme.surfaceLight
                : AppTheme.surfaceVariantLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: state == _DotState.done
                  ? AppTheme.accent
                  : state == _DotState.active
                  ? AppTheme.primary
                  : AppTheme.outlineLight,
              width: state == _DotState.active ? 2.5 : 1.5,
            ),
          ),
          child: Center(
            child: state == _DotState.done
                ? const CustomIconWidget(
                    iconName: 'check',
                    color: Colors.white,
                    size: 16,
                  )
                : state == _DotState.active
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: state == _DotState.active
                ? FontWeight.w600
                : FontWeight.w400,
            color: state == _DotState.pending
                ? AppTheme.onSurfaceMuted
                : AppTheme.primary,
          ),
        ),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isDone;
  const _StepConnector({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Row(
          children: List.generate(6, (i) {
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isDone ? AppTheme.accent : AppTheme.outlineLight,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
