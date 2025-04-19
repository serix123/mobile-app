import 'package:flutter/material.dart';
import 'package:online_reservation/Features/MedApplication/Data/Model/application.model.dart';

class GenderDropdown extends StatelessWidget {
  final Gender? value;
  final ValueChanged<Gender?> onChanged;
  final String? labelText;
  final String? hintText;
  final bool isExpanded;
  final FormFieldValidator<Gender>? validator;
  final bool autovalidateMode;

  const GenderDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.isExpanded = false,
    this.validator,
    this.autovalidateMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<Gender>(
      autovalidateMode: autovalidateMode
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      validator: validator,
      builder: (FormFieldState<Gender> field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            border: const OutlineInputBorder(),
            errorText: field.errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Gender>(
              value: value,
              isExpanded: isExpanded,
              onChanged: (Gender? newValue) {
                onChanged(newValue);
                field.didChange(newValue);
              },
              items: Gender.values.map((Gender gender) {
                return DropdownMenuItem<Gender>(
                  value: gender,
                  child: Text(gender.displayName),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
