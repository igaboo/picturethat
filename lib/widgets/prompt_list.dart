import 'package:flutter/material.dart';
import 'package:picturethat/models/prompt_model.dart';
import 'package:picturethat/widgets/prompt.dart';

class PromptList extends StatelessWidget {
  final List<PromptModel> prompts;

  const PromptList({
    required this.prompts,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: prompts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 30.0),
      itemBuilder: (context, index) {
        final prompt = prompts[index];
        return Prompt(
          prompt: prompt,
          key: ValueKey(prompt.id),
        );
      },
    );
  }
}
