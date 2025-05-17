import 'package:flutter/material.dart';
import 'package:picture_that/utils/text_validation.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool? obscureText;
  final bool? autofocus;
  final bool? autocorrect;
  final bool? multiline;
  final int? maxLength;
  final Widget? prefix;

  const CustomTextField({
    required this.label,
    required this.controller,
    this.validator,
    this.obscureText,
    this.autofocus,
    this.autocorrect,
    this.multiline,
    this.maxLength,
    this.prefix,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator ??
          (value) => textValidator(
                value: value,
                fieldName: label.toLowerCase(),
              ),
      obscureText: obscureText ?? false,
      autofocus: autofocus ?? false,
      autocorrect: autocorrect ?? true,
      maxLines: multiline == true ? null : 1,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        helperText: ' ',
        border: const OutlineInputBorder(),
        prefix: prefix,
      ),
    );
  }
}
