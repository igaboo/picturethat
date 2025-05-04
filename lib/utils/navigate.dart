import 'package:flutter/material.dart';

void navigateRoute(BuildContext context, Widget screen) {
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
