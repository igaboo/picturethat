import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:picture_that/auth_wrapper.dart';
import 'package:picture_that/screens/prompt_feed_screen.dart';
import 'package:picture_that/screens/edit_profile_screen.dart';
import 'package:picture_that/screens/tabs/feed_screen.dart';
import 'package:picture_that/screens/followers_screen.dart';
import 'package:picture_that/screens/tabs/home_screen.dart';
import 'package:picture_that/screens/tabs/profile_screen.dart';
import 'package:picture_that/screens/tabs/prompts_screen.dart';
import 'package:picture_that/screens/search_screen.dart';
import 'package:picture_that/screens/settings_screen.dart';
import 'package:picture_that/screens/submit_photo_screen.dart';
import 'package:picture_that/screens/authentication/landing_screen.dart';
import 'package:picture_that/screens/authentication/login_screen.dart';
import 'package:picture_that/screens/authentication/register_screen.dart';

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
        "/prompt_feed_screen": (context) => PromptFeedScreen(promptId: ""),
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
