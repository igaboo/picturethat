import 'package:flutter/material.dart';
import 'package:picture_that/utils/show_snackbar.dart';

enum CustomButtonType { filled, outlined, text }

class CustomButton extends StatefulWidget {
  final String label;
  final Function()? onPressed;
  final CustomButtonType? type;
  final bool? disabled;

  const CustomButton({
    required this.label,
    required this.onPressed,
    this.disabled = false,
    this.type = CustomButtonType.filled,
    super.key,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isLoading = false;

  void handleOnPressed() async {
    if (widget.onPressed == null) return;

    final result = widget.onPressed!();

    if (result is Future) {
      setState(() => isLoading = true);

      try {
        await result;
      } catch (e) {
        customShowSnackbar(e);
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled == true || isLoading;
    final child = isLoading
        ? const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(widget.label);

    switch (widget.type) {
      case CustomButtonType.outlined:
        return OutlinedButton(
          onPressed: isDisabled ? null : handleOnPressed,
          child: child,
        );
      case CustomButtonType.text:
        return TextButton(
          onPressed: isDisabled ? null : handleOnPressed,
          child: child,
        );
      default:
        return FilledButton(
          onPressed: isDisabled ? null : handleOnPressed,
          child: child,
        );
    }
  }
}
