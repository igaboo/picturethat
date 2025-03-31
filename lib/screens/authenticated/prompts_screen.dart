import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/providers/prompt_provider.dart';
import 'package:picturethat/widgets/prompt_list.dart';

class PromptsScreen extends ConsumerWidget {
  const PromptsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promptsAsync = ref.watch(promptsProvider);

    Future<void> refreshPrompts() async {
      ref.invalidate(promptsProvider);
      await ref.read(promptsProvider.future);
    }

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0.0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, "/submit_photo_screen"),
        label: Text("Submit Today's Prompt"),
        icon: Icon(Icons.add_photo_alternate_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomInset: false,
      body: RefreshIndicator(
          onRefresh: refreshPrompts,
          child: promptsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Error: $e")),
            data: (prompts) {
              if (prompts.isEmpty) {
                return const Center(child: Text("No prompts available"));
              }
              return PromptList(prompts: prompts);
            },
          )),
    );
  }
}
