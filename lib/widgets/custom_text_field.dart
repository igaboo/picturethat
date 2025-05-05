import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final IconButton? leadingButton;
  final IconButton? trailingButton;
  final bool? autofocus;
  final bool? autocorrect;

  const CustomTextField({
    required this.hintText,
    required this.controller,
    this.onChanged,
    this.leadingButton,
    this.trailingButton,
    this.autofocus,
    this.autocorrect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(150.0), // Rounded corners
      ),
      child: Row(
        children: [
          leadingButton != null ? leadingButton! : const SizedBox(width: 16.0),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus ?? false,
              autocorrect: autocorrect ?? true,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
          if (trailingButton != null) trailingButton!,
        ],
      ),
    );
  }
}
