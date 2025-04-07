import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/providers/prompt_provider.dart';
import 'package:picturethat/utils/navigate.dart';
import 'package:picturethat/widgets/prompt_list.dart';

class PromptsScreen extends ConsumerStatefulWidget {
  const PromptsScreen({super.key});

  @override
  ConsumerState<PromptsScreen> createState() => _PromptsScreenState();
}

class _PromptsScreenState extends ConsumerState<PromptsScreen> {
  Future<void> _refreshPrompts() async {
    ref.invalidate(promptsProvider);
    await ref.read(promptsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final promptsAsync = ref.watch(promptsProvider);

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0.0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => navigate(context, "/submit_photo_screen"),
        label: Text("Submit Today's Prompt"),
        icon: Icon(Icons.add_photo_alternate_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomInset: false,
      body: RefreshIndicator(
          onRefresh: _refreshPrompts,
          child: promptsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Error: $e")),
            data: (prompts) => PromptList(promptState: prompts),
          )),
    );
  }
}
