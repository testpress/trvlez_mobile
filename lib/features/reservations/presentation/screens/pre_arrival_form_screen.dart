import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/form.dart';
import 'package:trvlez_mobile/features/reservations/presentation/pre_arrival_form_notifier.dart';

class PreArrivalFormScreen extends ConsumerStatefulWidget {
  final String reservationId;

  const PreArrivalFormScreen({super.key, required this.reservationId});

  @override
  ConsumerState<PreArrivalFormScreen> createState() =>
      _PreArrivalFormScreenState();
}

class _PreArrivalFormScreenState extends ConsumerState<PreArrivalFormScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleSaveDraft() async {
    // We don't validate for draft saving
    final success = await ref
        .read(preArrivalFormProvider(widget.reservationId).notifier)
        .saveDraft();

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Draft saved successfully')));
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(preArrivalFormProvider(widget.reservationId).notifier)
        .submitForm();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(preArrivalFormProvider(widget.reservationId));
    final colors = context.colors;

    if (state.isLoading && state.formResponse == null) {
      return Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: colors.surface,
          title: Text(
            'Pre-Arrival Form',
            style: AppTypography.heading.copyWith(
              fontSize: 20,
              color: colors.textPrimary,
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: colors.brandPrimary),
        ),
      );
    }

    if (state.error != null && state.formResponse == null) {
      return Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: colors.surface,
          title: Text(
            'Pre-Arrival Form',
            style: AppTypography.heading.copyWith(
              fontSize: 20,
              color: colors.textPrimary,
            ),
          ),
        ),
        body: Center(
          child: Text(
            'Error: ${state.error}',
            style: AppTypography.body.copyWith(
              fontSize: 14,
              color: colors.feedbackError,
            ),
          ),
        ),
      );
    }

    final formResponse = state.formResponse!;
    final template = formResponse.template;
    final isReadOnly =
        formResponse.submission?.status == FormSubmissionStatus.submitted ||
        formResponse.submission?.status == FormSubmissionStatus.approved;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          template.title,
          style: AppTypography.heading.copyWith(
            fontSize: 20,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: template.formDefinition.sections.length,
          itemBuilder: (context, index) {
            final section = template.formDefinition.sections[index];
            return _buildSection(
              section,
              state.currentResponses,
              isReadOnly,
              colors,
            );
          },
        ),
      ),
      bottomNavigationBar: isReadOnly
          ? null
          : Container(
              padding: const EdgeInsets.all(
                AppSpacing.screenPadding,
              ).copyWith(top: AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.borderSubtle)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: state.isLoading ? null : _handleSaveDraft,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          side: BorderSide(color: colors.borderSubtle),
                          foregroundColor: colors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: state.isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.brandPrimary,
                                ),
                              )
                            : Text(
                                'Save Draft',
                                style: AppTypography.label.copyWith(
                                  fontSize: 14,
                                  color: colors.textPrimary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: state.isLoading ? null : _handleSubmit,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.brandPrimary,
                          foregroundColor: colors.brandOnSurface,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Text(
                          'Submit',
                          style: AppTypography.label.copyWith(
                            fontSize: 14,
                            color: colors.brandOnSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection(
    FormSection section,
    Map<String, dynamic> responses,
    bool isReadOnly,
    AppColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: AppTypography.heading.copyWith(
            fontSize: 18,
            color: colors.brandPrimary,
          ),
        ),
        if (section.description != null && section.description!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            section.description!,
            style: AppTypography.body.copyWith(
              fontSize: 14,
              color: colors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        ...section.fields.map(
          (field) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildField(field, responses[field.id], isReadOnly),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildField(
    FormFieldDefinition field,
    dynamic currentValue,
    bool isReadOnly,
  ) {
    if (field.type == 'boolean' || field.type == 'checkbox') {
      return CheckboxListTile(
        title: Text(field.label),
        value: currentValue == true,
        onChanged: isReadOnly
            ? null
            : (val) {
                ref
                    .read(preArrivalFormProvider(widget.reservationId).notifier)
                    .updateField(field.id, val);
              },
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      );
    }

    if (field.options != null && field.options!.isNotEmpty) {
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
        ),
        initialValue: currentValue?.toString(),
        items: field.options!
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: isReadOnly
            ? null
            : (val) {
                ref
                    .read(preArrivalFormProvider(widget.reservationId).notifier)
                    .updateField(field.id, val);
              },
        validator: field.isRequired
            ? (val) {
                if (val == null || val.isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
            : null,
      );
    }

    TextInputType keyboardType = TextInputType.text;
    if (field.type == 'email') keyboardType = TextInputType.emailAddress;
    if (field.type == 'phone') keyboardType = TextInputType.phone;
    if (field.type == 'number') keyboardType = TextInputType.number;

    return TextFormField(
      initialValue: currentValue?.toString() ?? '',
      decoration: InputDecoration(
        labelText: field.label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      readOnly: isReadOnly,
      onChanged: (val) {
        ref
            .read(preArrivalFormProvider(widget.reservationId).notifier)
            .updateField(field.id, val);
      },
      validator: field.isRequired
          ? (val) {
              if (val == null || val.isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }
}
