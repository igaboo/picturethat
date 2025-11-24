import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picture_that/main.dart';
import 'package:picture_that/utils/helpers.dart';

void customShowSnackbar(
  dynamic e, {
  SnackBarAction? action,
}) {
  String errorMessage = e.toString();

  if (e is FirebaseAuthException || e is PlatformException) {
    errorMessage = getErrorMessage(e.code);
  }

  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      behavior: SnackBarBehavior.floating,
      action: action,
    ),
  );
}
