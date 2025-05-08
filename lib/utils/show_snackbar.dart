import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:picture_that/main.dart';
import 'package:picture_that/utils/helpers.dart';

void customShowSnackbar(
  dynamic e, {
  SnackBarAction? action,
}) {
  String errorMessage;

  if (e is FirebaseAuthException) {
    errorMessage = getErrorMessage(e.code);
  } else if (e is Exception) {
    errorMessage = e.toString().replaceFirst("Exception: ", "");
  } else {
    errorMessage = e.toString();
  }

  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      behavior: SnackBarBehavior.floating,
      action: action,
    ),
  );
}
