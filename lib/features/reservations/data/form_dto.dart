import 'package:trvlez_mobile/features/reservations/domain/form.dart';

class FormFieldDefinitionDto {
  final String id;
  final String type;
  final String label;
  final bool isRequired;
  final String? preFillAlias;
  final List<String>? options;

  const FormFieldDefinitionDto({
    required this.id,
    required this.type,
    required this.label,
    required this.isRequired,
    this.preFillAlias,
    this.options,
  });

  factory FormFieldDefinitionDto.fromJson(Map<String, dynamic> json) {
    return FormFieldDefinitionDto(
      id: json['id'] as String,
      type: json['type'] as String,
      label: json['label'] as String,
      isRequired: json['required'] as bool? ?? false,
      preFillAlias: json['pre_fill_alias'] as String?,
      options: (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  FormFieldDefinition toDomain() {
    return FormFieldDefinition(
      id: id,
      type: type,
      label: label,
      isRequired: isRequired,
      preFillAlias: preFillAlias,
      options: options,
    );
  }
}

class FormSectionDto {
  final String title;
  final String? description;
  final List<FormFieldDefinitionDto> fields;

  const FormSectionDto({
    required this.title,
    this.description,
    required this.fields,
  });

  factory FormSectionDto.fromJson(Map<String, dynamic> json) {
    return FormSectionDto(
      title: json['title'] as String,
      description: json['description'] as String?,
      fields: (json['fields'] as List<dynamic>?)
              ?.map((e) => FormFieldDefinitionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  FormSection toDomain() {
    return FormSection(
      title: title,
      description: description,
      fields: fields.map((f) => f.toDomain()).toList(),
    );
  }
}

class FormDefinitionDto {
  final int version;
  final List<FormSectionDto> sections;

  const FormDefinitionDto({
    required this.version,
    required this.sections,
  });

  factory FormDefinitionDto.fromJson(Map<String, dynamic> json) {
    return FormDefinitionDto(
      version: json['version'] as int? ?? 1,
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => FormSectionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  FormDefinition toDomain() {
    return FormDefinition(
      version: version,
      sections: sections.map((s) => s.toDomain()).toList(),
    );
  }
}

class FormTemplateDto {
  final String id;
  final String title;
  final String? description;
  final FormDefinitionDto formDefinition;

  const FormTemplateDto({
    required this.id,
    required this.title,
    this.description,
    required this.formDefinition,
  });

  factory FormTemplateDto.fromJson(Map<String, dynamic> json) {
    return FormTemplateDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      formDefinition: FormDefinitionDto.fromJson(json['form_definition'] as Map<String, dynamic>),
    );
  }

  FormTemplate toDomain() {
    return FormTemplate(
      id: id,
      title: title,
      description: description,
      formDefinition: formDefinition.toDomain(),
    );
  }
}

class FormSubmissionDto {
  final String id;
  final String status;
  final Map<String, dynamic> responses;

  const FormSubmissionDto({
    required this.id,
    required this.status,
    required this.responses,
  });

  factory FormSubmissionDto.fromJson(Map<String, dynamic> json) {
    return FormSubmissionDto(
      id: json['id'] as String,
      status: json['status'] as String,
      responses: json['responses'] as Map<String, dynamic>? ?? {},
    );
  }

  FormSubmission toDomain() {
    return FormSubmission(
      id: id,
      status: FormSubmissionStatus.fromString(status),
      responses: responses,
    );
  }
}

class ReservationFormResponseDto {
  final FormTemplateDto template;
  final FormSubmissionDto? submission;
  final Map<String, dynamic> preFillData;

  const ReservationFormResponseDto({
    required this.template,
    this.submission,
    required this.preFillData,
  });

  factory ReservationFormResponseDto.fromJson(Map<String, dynamic> json) {
    return ReservationFormResponseDto(
      template: FormTemplateDto.fromJson(json['template'] as Map<String, dynamic>),
      submission: json['submission'] != null
          ? FormSubmissionDto.fromJson(json['submission'] as Map<String, dynamic>)
          : null,
      preFillData: json['pre_fill_data'] as Map<String, dynamic>? ?? {},
    );
  }

  ReservationFormResponse toDomain() {
    return ReservationFormResponse(
      template: template.toDomain(),
      submission: submission?.toDomain(),
      preFillData: preFillData,
    );
  }
}
