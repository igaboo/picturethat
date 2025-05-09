import 'package:flutter/material.dart';
import 'package:picture_that/utils/show_snackbar.dart';

enum CustomButtonType { filled, outlined, text }

class CustomButton extends StatefulWidget {
  final String label;
  final Function()? onPressed;
  final CustomButtonType? type;
  final bool? disabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? outlineColor;
  final Widget? prefix;

  const CustomButton({
    required this.label,
    required this.onPressed,
    this.disabled = false,
    this.type = CustomButtonType.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.outlineColor,
    this.prefix,
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
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8.0,
            children: [
              if (widget.prefix != null) widget.prefix!,
              Text(widget.label)
            ],
          );

    switch (widget.type) {
      case CustomButtonType.outlined:
        return OutlinedButton(
          key: ValueKey("outlined"),
          onPressed: isDisabled ? null : handleOnPressed,
          child: child,
        );
      case CustomButtonType.text:
        return TextButton(
          key: ValueKey("text"),
          onPressed: isDisabled ? null : handleOnPressed,
          child: child,
        );
      default:
        return FilledButton(
          key: ValueKey("filled"),
          onPressed: isDisabled ? null : handleOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            side: widget.outlineColor != null
                ? BorderSide(color: widget.outlineColor!)
                : null,
          ),
          child: child,
        );
    }
  }
}
