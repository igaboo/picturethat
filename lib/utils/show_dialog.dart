import 'package:flutter/material.dart';
import 'package:picture_that/utils/helpers.dart';

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
            onPressed: navigateBack,
            child: Text(cancelText ?? "Cancel"),
          ),
          TextButton(
            onPressed: () {
              onPressed();
              navigateBack();
            },
            child: Text(buttonText ?? "Okay"),
          )
        ],
      );
    },
  );
}
