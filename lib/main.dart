import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:picturethat/screens/authenticated/edit_profile.dart';
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
import 'package:picturethat/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Picture That",
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      darkTheme: ThemeData.dark(),
      initialRoute: "/",
      routes: {
        "/": (context) => SplashScreen(),
        "/landing": (context) => LandingScreen(),
        "/login": (context) => LoginScreen(),
        "/register": (context) => RegisterScreen(),
        "/home": (context) => Home(),
        "/prompts": (context) => PromptsScreen(),
        "/feed": (context) => FeedScreen(),
        "/profile": (context) => ProfileScreen(),
        "/submit-photo": (context) => SubmitPhotoScreen(),
        "/settings": (context) => SettingsScreen(),
        "/edit-profile": (context) => EditProfileScreen(),
        "/search": (context) => SearchScreen(),
        "/followers": (context) => FollowersScreen(),
      },
    );
  }
}
