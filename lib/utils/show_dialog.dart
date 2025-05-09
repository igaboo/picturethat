import 'dart:async';

import 'package:flutter/material.dart';
import 'package:picture_that/utils/helpers.dart';

Future<void> customShowDialog({
  required BuildContext context,
  required String title,
  required String content,
  required FutureOr<void> Function() onPressed,
  String? buttonText,
  String? cancelText,
}) {
  return showDialog(
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
            onPressed: () async {
              await onPressed();
            },
            child: Text(buttonText ?? "Okay"),
          )
        ],
      );
    },
  );
}
