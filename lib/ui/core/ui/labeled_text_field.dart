import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imobi_app/ui/core/themes/app_colors.dart';

/// Border of a field with an error. Danger is used only on borders and icons;
/// the message stays dark (contrast decision 1 in the imobibrasil-design
/// skill).
const errorInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  borderSide: BorderSide(color: AppColors.danger, width: 2),
);

/// Text field with the label above the box; an error shows as red border +
/// ⚠ icon + dark message below. Shared by every form in the app.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.focusNode,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.minLines,
    this.maxLines = 1,
    this.obscureText = false,
    this.suffixIcon,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final int? minLines;
  final int maxLines;
  final bool obscureText;

  /// An action inside the box (e.g. show password). It replaces the ⚠ icon;
  /// the red border and the message still show the error.
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final validator = this.validator;
    final suffixIcon = this.suffixIcon;
    return FormField<String>(
      initialValue: controller.text,
      validator: validator == null ? null : (_) => validator(controller.text),
      builder: (field) {
        final error = field.errorText;
        final textField = TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) {
            field.didChange(value);
            onChanged?.call(value);
          },
          onSubmitted: onSubmitted,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          minLines: minLines,
          maxLines: maxLines,
          obscureText: obscureText,
          autofillHints: autofillHints,
          decoration: InputDecoration(
            isDense: true,
            suffixIcon:
                suffixIcon ??
                (error == null
                    ? null
                    : const Icon(Icons.error_outline, color: AppColors.danger)),
            enabledBorder: error == null ? null : errorInputBorder,
            focusedBorder: error == null ? null : errorInputBorder,
          ),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Merged so a screen reader reads the label with the field. A
            // field with its own action keeps them apart: merging would hide
            // the action inside the field.
            if (suffixIcon == null)
              MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: label, isRequired: isRequired),
                    textField,
                  ],
                ),
              )
            else ...[
              FieldLabel(label: label, isRequired: isRequired),
              textField,
            ],
            if (error != null) ErrorLine(message: error),
          ],
        );
      },
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.label, this.isRequired = false});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        isRequired ? '$label *' : label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class ErrorLine extends StatelessWidget {
  const ErrorLine({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.danger),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
