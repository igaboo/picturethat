import 'package:flutter/material.dart';

void navigate(BuildContext context, Widget screen) {
  if (ModalRoute.of(context)?.settings.name == screen.runtimeType.toString()) {
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => screen,
      settings: RouteSettings(name: screen.runtimeType.toString()),
    ),
  );
}

void navigateAndDisableBack(BuildContext context, Widget screen) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => screen),
    (route) => false,
  );
}
