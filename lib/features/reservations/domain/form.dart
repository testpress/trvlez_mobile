enum FormSubmissionStatus {
  draft,
  submitted,
  approved,
  rejected,
  resubmissionRequested;

  static FormSubmissionStatus fromString(String value) {
    switch (value) {
      case 'draft':
        return FormSubmissionStatus.draft;
      case 'submitted':
        return FormSubmissionStatus.submitted;
      case 'approved':
        return FormSubmissionStatus.approved;
      case 'rejected':
        return FormSubmissionStatus.rejected;
      case 'resubmission_requested':
        return FormSubmissionStatus.resubmissionRequested;
      default:
        return FormSubmissionStatus.draft;
    }
  }
}

/// Represents a field definition in a form section.
class FormFieldDefinition {
  final String id;
  final String type; // text, number, date, boolean, etc.
  final String label;
  final bool isRequired;
  final String? preFillAlias;
  final List<String>? options;

  const FormFieldDefinition({
    required this.id,
    required this.type,
    required this.label,
    required this.isRequired,
    this.preFillAlias,
    this.options,
  });
}

/// Represents a section in the form.
class FormSection {
  final String title;
  final String? description;
  final List<FormFieldDefinition> fields;

  const FormSection({
    required this.title,
    this.description,
    required this.fields,
  });
}

/// The structure of the form template.
class FormDefinition {
  final int version;
  final List<FormSection> sections;

  const FormDefinition({
    required this.version,
    required this.sections,
  });
}

/// A form template configured by the property.
class FormTemplate {
  final String id;
  final String title;
  final String? description;
  final FormDefinition formDefinition;

  const FormTemplate({
    required this.id,
    required this.title,
    this.description,
    required this.formDefinition,
  });
}

/// A form submission for a reservation.
class FormSubmission {
  final String id;
  final FormSubmissionStatus status;
  final Map<String, dynamic> responses;

  const FormSubmission({
    required this.id,
    required this.status,
    required this.responses,
  });
}

/// The response payload when fetching a reservation's form.
class ReservationFormResponse {
  final FormTemplate template;
  final FormSubmission? submission;
  final Map<String, dynamic> preFillData;

  const ReservationFormResponse({
    required this.template,
    this.submission,
    required this.preFillData,
  });
}
