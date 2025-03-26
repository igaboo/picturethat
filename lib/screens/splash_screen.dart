import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, "/landing");
    });

    return const Scaffold(
      body: Center(
        child: Text("Splash Screen"),
      ),
    );
  }
}
