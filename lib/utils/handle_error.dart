import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:picturethat/utils/get_error_message.dart';

void handleError(BuildContext context, dynamic e) {
  String errorMessage;

  if (e is FirebaseAuthException) {
    errorMessage = getErrorMessage(e.code);
  } else if (e is Exception) {
    errorMessage = e.toString().replaceFirst("Exception: ", "");
  } else {
    errorMessage = e.toString();
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorMessage),
    ),
  );
}
