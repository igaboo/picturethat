import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/models/prompt_model.dart';
import 'package:picturethat/providers/prompt_provider.dart';
import 'package:picturethat/utils/navigate.dart';
import 'package:picturethat/widgets/custom_skeletonizer.dart';
import 'package:picturethat/widgets/custom_tooltip.dart';
import 'package:picturethat/widgets/prompt.dart';
import 'package:picturethat/widgets/prompt_list.dart';

final skeleton = CustomSkeletonizer(
  child: ListView.separated(
    itemBuilder: (context, index) {
      return Prompt(
        prompt: PromptModel(
          id: "skeleton",
          title: "skeleton",
          date: DateTime.now().subtract(Duration(days: index)),
          submissionCount: 0,
          imageUrl: "https://dummyimage.com/1x1/0011ff/0011ff.png",
          imageAuthorName: "skeleton",
        ),
      );
    },
    separatorBuilder: (context, index) => SizedBox(height: 30.0),
    itemCount: 10,
  ),
);

class PromptsScreen extends ConsumerStatefulWidget {
  const PromptsScreen({super.key});

  @override
  ConsumerState<PromptsScreen> createState() => _PromptsScreenState();
}

class _PromptsScreenState extends ConsumerState<PromptsScreen>
    with AutomaticKeepAliveClientMixin<PromptsScreen> {
  @override
  bool get wantKeepAlive => true;

  Future<void> _refreshPrompts() async {
    ref.invalidate(promptsProvider);
    await ref.read(promptsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshPrompts,
            child: promptsAsync.when(
              loading: () => skeleton,
              error: (e, _) => Center(child: Text("Error: $e")),
              data: (prompts) => PromptList(promptState: prompts),
            ),
          ),
          Positioned(
            bottom: 70.0,
            left: 0,
            right: 0,
            child: CustomTooltip(
              tooltipId: "promptsTooltip",
              title: "Prompts",
              message:
                  "A new prompt is available every day. Only today's prompt is available to submit, so make sure to check back every day!",
            ),
          ),
        ],
      ),
    );
  }
}
