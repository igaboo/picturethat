import 'package:flutter/material.dart';

void navigate(
  BuildContext context,
  String route, {
  Object? arguments,
}) {
  final ModalRoute<dynamic>? currentRoute = ModalRoute.of(context);

  final String? currentRouteName = currentRoute?.settings.name;

  print(currentRoute);

  if (currentRouteName != route) {
    Navigator.pushNamed(context, route, arguments: arguments);
  }
}
