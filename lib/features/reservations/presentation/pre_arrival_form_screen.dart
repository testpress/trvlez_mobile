import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:trvlez_mobile/features/reservations/domain/form.dart';
import 'package:trvlez_mobile/features/reservations/presentation/pre_arrival_form_notifier.dart';

class PreArrivalFormScreen extends ConsumerStatefulWidget {
  final String reservationId;

  const PreArrivalFormScreen({
    super.key,
    required this.reservationId,
  });

  @override
  ConsumerState<PreArrivalFormScreen> createState() => _PreArrivalFormScreenState();
}

class _PreArrivalFormScreenState extends ConsumerState<PreArrivalFormScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleSaveDraft() async {
    // We don't validate for draft saving
    final success = await ref
        .read(preArrivalFormProvider(widget.reservationId).notifier)
        .saveDraft();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved successfully')),
      );
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
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isLoading && state.formResponse == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pre-Arrival Form')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null && state.formResponse == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pre-Arrival Form')),
        body: Center(child: Text('Error: ${state.error}')),
      );
    }

    final formResponse = state.formResponse!;
    final template = formResponse.template;
    final isReadOnly = formResponse.submission?.status == FormSubmissionStatus.submitted ||
        formResponse.submission?.status == FormSubmissionStatus.approved;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          template.title,
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: template.formDefinition.sections.length,
          itemBuilder: (context, index) {
            final section = template.formDefinition.sections[index];
            return _buildSection(section, state.currentResponses, isReadOnly, colorScheme);
          },
        ),
      ),
      bottomNavigationBar: isReadOnly
          ? null
          : Container(
              padding: const EdgeInsets.all(24).copyWith(top: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: state.isLoading ? null : _handleSaveDraft,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save Draft'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: state.isLoading ? null : _handleSubmit,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Submit'),
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
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
        if (section.description != null && section.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            section.description!,
            style: GoogleFonts.cabin(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 16),
        ...section.fields.map(
          (field) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildField(field, responses[field.id], isReadOnly),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildField(FormFieldDefinition field, dynamic currentValue, bool isReadOnly) {
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
            .map(
              (o) => DropdownMenuItem(
                value: o,
                child: Text(o),
              ),
            )
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
