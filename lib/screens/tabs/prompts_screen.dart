import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/models/prompt_model.dart';
import 'package:picture_that/providers/prompt_provider.dart';
import 'package:picture_that/screens/submit_photo_screen.dart';
import 'package:picture_that/screens/tabs/feed_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/widgets/custom_skeletonizer.dart';
import 'package:picture_that/widgets/common/custom_tooltip.dart';
import 'package:picture_that/widgets/prompt/prompt.dart';
import 'package:picture_that/widgets/prompt/prompt_list.dart';

final promptsListSkeleton = CustomSkeletonizer(
  child: ListView.separated(
    itemCount: 3,
    separatorBuilder: (context, index) => SizedBox(height: 30.0),
    itemBuilder: (context, index) {
      return Prompt(prompt: getDummyPrompt(index: index));
    },
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
        onPressed: () => navigate(const SubmitPhotoScreen()),
        label: Text("Submit Today's Prompt"),
        icon: Icon(Icons.add_a_photo),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshPrompts,
            child: promptsAsync.when(
              loading: () => promptsListSkeleton,
              error: (e, _) => ErrorEmptyState(
                callback: _refreshPrompts,
                description:
                    "An error occurred while fetching prompts. Please try again later.",
              ),
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
