import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:picturethat/screens/authenticated/home_screen.dart';
import 'package:picturethat/screens/landing_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // show a loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // if user is authenticated, show Home screen
        if (snapshot.hasData) {
          return Home();
        }

        // if user is not authenticated, show Landing screen
        return LandingScreen();
      },
    );
  }
}
