import 'package:flutter/material.dart';

class FollowersScreen extends StatelessWidget {
  const FollowersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // determine uid from arguments
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final type = args["type"] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(type),
      ),
      body: Center(
        child: Text("$type Screen"),
      ),
    );
  }
}
