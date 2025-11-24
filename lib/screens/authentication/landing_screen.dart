import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/screens/authentication/register_screen.dart';
import 'package:picture_that/screens/tabs/home_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/widgets/common/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
        backgroundColor: colorScheme.primaryContainer.withAlpha(100),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [
                0.0,
                0.8
              ],
              colors: [
                colorScheme.primaryContainer.withAlpha(100),
                colorScheme.surface,
              ]),
        ),
        child: SafeArea(
          maintainBottomViewPadding: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 32.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 350),
                  child: Column(
                    spacing: 10.0,
                    children: [
                      Text(
                        "A fresh perspective, every day.",
                        textAlign: TextAlign.center,
                        style: textTheme.displaySmall!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "A new photo prompt daily—capture it your way, share your work, and explore others' interpretations.",
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isAndroid)
                          CustomButton(
                            label: "Continue with Apple",
                            onPressed: () {},
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            outlineColor: Colors.black.withAlpha(50),
                            prefix: Image.asset(
                              "assets/apple.png",
                              width: 20,
                              height: 20,
                            ),
                          ),
                        CustomButton(
                          label: "Continue with Google",
                          onPressed: () async {
                            final credential = await signInWithGoogle();

                            if (credential != null) {
                              navigateAndDisableBack(Home());
                            }
                          },
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          outlineColor: Colors.black.withAlpha(50),
                          prefix: Image.asset(
                            "assets/google.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                        CustomButton(
                          label: "Or continue with email",
                          onPressed: () => navigate(const RegisterScreen()),
                          type: CustomButtonType.text,
                        ),
                      ],
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: textTheme.bodyMedium!.copyWith(
                          color: colorScheme.secondary,
                        ),
                        children: [
                          TextSpan(text: "By continuing, you agree to our \n"),
                          TextSpan(
                            text: "Terms of Service",
                            style: TextStyle(
                                color: colorScheme.primary,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launchUrl(
                                  Uri.parse("https://www.google.com")),
                          ),
                          TextSpan(text: " and "),
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                                color: colorScheme.primary,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launchUrl(
                                  Uri.parse("https://www.google.com")),
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
      ),
    );
  }
}
