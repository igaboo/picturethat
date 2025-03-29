import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/models/prompt_model.dart';
import 'package:picturethat/providers/prompt_provider.dart';
import 'package:picturethat/providers/submission_provider.dart';
import 'package:picturethat/utils/is_today.dart';
import 'package:picturethat/widgets/submission_list.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promptId = ModalRoute.of(context)?.settings.arguments as String?;
    final bool isPrompt = promptId != null;
    AsyncValue<PromptModel?> promptAsync = const AsyncValue.data(null);
    if (isPrompt) {
      promptAsync = ref.watch(promptProvider(promptId));
    }
    final SubmissionQueryParam queryParam;
    if (isPrompt) {
      queryParam =
          (type: SubmissionQueryType.byPrompt, id: promptId, user: null);
    } else {
      queryParam = (type: SubmissionQueryType.all, id: null, user: null);
    }
    bool isTodaysPrompt = isToday(promptAsync.value?.date ?? DateTime.now());

    final submissionAsync = ref.watch(submissionNotifierProvider(queryParam));

    Future<void> refreshSubmissions() async {
      ref.invalidate(submissionNotifierProvider(queryParam));
      await ref.read(submissionNotifierProvider(queryParam).future);
    }

    return Scaffold(
      appBar: AppBar(
        title: isPrompt
            ? promptAsync.when(
                loading: () => Text("Loading..."),
                error: (e, _) => Text("Error: $e"),
                data: (prompt) => Text(prompt?.title ?? "Feed"),
              )
            : const Text("Feed"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, "/search_screen");
            },
          ),
        ],
      ),
      floatingActionButton: isTodaysPrompt
          ? FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, "/submit_photo_screen"),
              label: Text("Submit Prompt"),
              icon: Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomInset: false,
      body: submissionAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (submissions) {
          if (submissions.isEmpty) {
            return Center(child: Text("No submissions found"));
          }

          return RefreshIndicator(
            onRefresh: refreshSubmissions,
            child: SubmissionList(
                submissions: submissions, queryParam: queryParam),
          );
        },
      ),
    );
  }
}
