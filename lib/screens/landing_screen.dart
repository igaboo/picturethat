import 'package:flutter/material.dart';
import 'package:picturethat/widgets/custom_image.dart';
import 'dart:math' as math;

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0), // hides header
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Images
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: -10 * math.pi / 180,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: CustomNetworkImage(
                          url:
                              "https://media.istockphoto.com/id/1317323736/photo/a-view-up-into-the-trees-direction-sky.jpg?s=612x612&w=0&k=20&c=i4HYO7xhao7CkGy7Zc_8XSNX_iqG0vAwNsrH1ERmw2Q=",
                          width: 180,
                          height: 280,
                        ),
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: 10 * math.pi / 180,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CustomNetworkImage(
                        url:
                            "https://img.freepik.com/free-photo/amazing-ants-carry-fruit-heavier-than-their-bodies-amazing-strong-ant_488145-2669.jpg?semt=ais_hybrid",
                        width: 180,
                        height: 280,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: CustomNetworkImage(
                      url:
                          "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
                      width: 230,
                      height: 330,
                    ),
                  ),
                ],
              ),
            ),
            // Text Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
