import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

import 'package:picturethat/auth_wrapper.dart';
import 'package:picturethat/screens/authenticated/edit_profile_screen.dart';
import 'package:picturethat/screens/authenticated/feed_screen.dart';
import 'package:picturethat/screens/authenticated/followers_screen.dart';
import 'package:picturethat/screens/authenticated/home_screen.dart';
import 'package:picturethat/screens/authenticated/profile_screen.dart';
import 'package:picturethat/screens/authenticated/prompts_screen.dart';
import 'package:picturethat/screens/authenticated/search_screen.dart';
import 'package:picturethat/screens/authenticated/settings_screen.dart';
import 'package:picturethat/screens/authenticated/submit_photo_screen.dart';
import 'package:picturethat/screens/landing_screen.dart';
import 'package:picturethat/screens/login_screen.dart';
import 'package:picturethat/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Picture That",
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.yellow,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.yellow,
      ),
      home: AuthWrapper(),
      routes: {
        "/landing_screen": (context) => LandingScreen(),
        "/login_screen": (context) => LoginScreen(),
        "/register_screen": (context) => RegisterScreen(),
        "/home_screen": (context) => Home(),
        "/prompts_screen": (context) => PromptsScreen(),
        "/feed_screen": (context) => FeedScreen(),
        "/profile_screen": (context) => ProfileScreen(),
        "/submit_photo_screen": (context) => SubmitPhotoScreen(),
        "/settings_screen": (context) => SettingsScreen(),
        "/edit_profile_screen": (context) => EditProfileScreen(),
        "/search_screen": (context) => SearchScreen(),
        "/followers_screen": (context) => FollowersScreen(),
      },
    );
  }
}
