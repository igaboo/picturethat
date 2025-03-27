import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:picturethat/utils/get_error_message.dart';

void handleError(BuildContext context, dynamic e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        e is FirebaseAuthException ? getErrorMessage(e.code) : e.toString(),
      ),
    ),
  );
}
