import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/screens/tabs/home_screen.dart';
import 'package:picturethat/screens/authentication/landing_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
