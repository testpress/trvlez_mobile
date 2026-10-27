import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen allowing the traveler to report friction or issues encountered during verification.
///
/// Features multi-select complaint tags, context notes with smart auto-ticking,
/// and a prominent fraud safety warning.
class ReportAProblemScreen extends StatefulWidget {
  const ReportAProblemScreen({super.key, this.contextData});

  final ProblemReportContext? contextData;

  @override
  State<ReportAProblemScreen> createState() => _ReportAProblemScreenState();
}

class _ReportAProblemScreenState extends State<ReportAProblemScreen> {
  final Set<int> _selected = {};
  final TextEditingController _notes = TextEditingController();
  bool _autoTicked = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _notes.addListener(_onNotesChanged);
  }

  void _onNotesChanged() {
    final problems = _currentArea.problems;
    final somethingElseIndex = problems.length - 1;
    final hasText = _notes.text.trim().isNotEmpty;

    if (hasText && !_selected.contains(somethingElseIndex)) {
      setState(() {
        _selected.add(somethingElseIndex);
        _autoTicked = true;
      });
    } else if (!hasText && _autoTicked) {
      setState(() {
        _selected.remove(somethingElseIndex);
        _autoTicked = false;
      });
    }
  }

  ProblemArea get _currentArea =>
      widget.contextData?.area ?? ProblemArea.verification;

  @override
  void dispose() {
    _notes.removeListener(_onNotesChanged);
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selected.isEmpty && _notes.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you. Your feedback has been sent to support.'),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final problems = _currentArea.problems;
    final canSubmit = _selected.isNotEmpty || _notes.text.trim().isNotEmpty;

    return BrandVerifyScreen(
      backgroundAsset: 'assets/art/bg_report_problem.svg',
      title: 'Report a problem',
      closeIcon: true,
      helpLine: false,
      isScrollable: true,
      onBack: () => context.pop(),
      body: [
        SizedBox(height: space.stackSection),
        Text(
          'Tell us what went wrong',
          style: context.text.headlineSmall?.copyWith(
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: space.stackTight),
        Text(
          "We'll attach your step, device model and app version so support has context.",
          style: context.text.bodySmall?.copyWith(
            color: colors.brandSecondaryBody,
            height: 1.4,
          ),
        ),
        SizedBox(height: space.stackFormField),
        Wrap(
          spacing: space.inlineIconLabel,
          runSpacing: space.stackItem,
          children: [
            for (int i = 0; i < problems.length; i++)
              _ProblemChip(
                label: problems[i],
                isSelected: _selected.contains(i),
                onTap: () {
                  setState(() {
                    if (_selected.contains(i)) {
                      _selected.remove(i);
                    } else {
                      _selected.add(i);
                    }
                  });
                },
              ),
          ],
        ),
        SizedBox(height: space.stackFormField),
        TextField(
          controller: _notes,
          maxLines: 4,
          style: context.text.bodyMedium?.copyWith(
            color: colors.brandOnSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Additional details (optional)…',
            hintStyle: context.text.bodyMedium?.copyWith(
              color: colors.brandSecondaryBody,
            ),
            filled: true,
            fillColor: colors.brandCardBackground,
            border: OutlineInputBorder(
              borderRadius: shape.radiusControl,
              borderSide: BorderSide.none,
            ),
            contentPadding: space.insetCard,
          ),
        ),
        SizedBox(height: space.stackFormField),
        Container(
          padding: space.insetCard,
          decoration: BoxDecoration(
            color: colors.brandShotBackdrop.withValues(alpha: 0.15),
            borderRadius: shape.radiusControl,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.shieldCheck,
                size: sizes.iconSm,
                color: colors.brandSecondary,
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Text(
                  'Never send photos of your passport by message. We will never ask you to.',
                  style: context.text.bodySmall?.copyWith(
                    fontWeight: TypeScale.medium,
                    color: colors.brandSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      foot: [
        AppButton(
          label: 'Send report',
          variant: AppButtonVariant.brandWhite,
          isLoading: _isSubmitting,
          enabled: canSubmit && !_isSubmitting,
          onPressed: canSubmit ? _submitReport : null,
        ),
      ],
    );
  }
}

class _ProblemChip extends StatelessWidget {
  const _ProblemChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: shape.radiusPill,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: space.stackFormField - space.stackText / 2,
            vertical: space.stackItem,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.brandOnSurface
                : colors.brandCardBackground,
            borderRadius: shape.radiusPill,
            border: Border.all(
              color: isSelected
                  ? colors.brandOnSurface
                  : colors.brandBorderSubtle,
              width: shape.borderDefault,
            ),
          ),
          child: Text(
            label,
            style: context.text.labelMedium?.copyWith(
              fontWeight: isSelected ? TypeScale.semiBold : TypeScale.regular,
              color: isSelected ? colors.brandPrimary : colors.brandOnSurface,
            ),
          ),
        ),
      ),
    );
  }
}
