import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0), // hides header
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Images
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Image(
                  image: AssetImage("assets/hero.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Text
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
              child: Column(
                spacing: 10.0,
                children: [
                  Text(
                    "A fresh perspective, every day.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  Text(
                    "A new photo prompt daily—capture it your way, share your work, and explore others’ interpretations.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.only(
                left: 32.0,
                right: 32.0,
                bottom: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16.0,
                children: [
                  FilledButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/register_screen");
                    },
                    child: Text("Create an Account"),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/login_screen");
                    },
                    child: Text("Login"),
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                      children: [
                        TextSpan(text: "By continuing, you agree to our \n"),
                        TextSpan(
                          text: "Terms of Service",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () =>
                                launchUrl(Uri.parse("https://www.google.com")),
                        ),
                        TextSpan(text: " and "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () =>
                                launchUrl(Uri.parse("https://www.google.com")),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
