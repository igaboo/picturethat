import 'package:flutter/material.dart';

void customShowDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onPressed,
  String? buttonText,
  String? cancelText,
}) {
  showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(cancelText ?? "Cancel"),
            ),
            TextButton(
              onPressed: () {
                onPressed();
                Navigator.of(context).pop();
              },
              child: Text(buttonText ?? "Okay"),
            )
          ],
        );
      });
}
