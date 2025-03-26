import 'package:flutter/material.dart';
import 'package:picturethat/utils/getFormattedDate.dart';

class PromptsScreen extends StatelessWidget {
  const PromptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(getFormattedDate(DateTime.now()))),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Text("Prompts Screen"),
      ),
    );
  }
}
