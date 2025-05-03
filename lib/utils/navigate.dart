import 'package:flutter/material.dart';

void navigate(
  BuildContext context,
  String route, {
  Object? arguments,
}) {
  final ModalRoute<dynamic>? currentRoute = ModalRoute.of(context);
  final String? currentRouteName = currentRoute?.settings.name;

  if (currentRouteName == route) return;

  Navigator.pushNamed(context, route, arguments: arguments);
}

void navigateRoute(BuildContext context, Widget targetWidget, String route) {
  final ModalRoute<dynamic>? currentRoute = ModalRoute.of(context);
  final String? currentRouteName = currentRoute?.settings.name;

  if (currentRouteName == route) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => targetWidget,
      settings: RouteSettings(name: route),
    ),
  );
}
