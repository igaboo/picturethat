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
    // get prompt id from args
    // if prompt id is null, then we are on the main feed
    final promptId = ModalRoute.of(context)?.settings.arguments as String?;
    final bool isPrompt = promptId != null;
    final AsyncValue<PromptModel?> promptAsync = isPrompt
        ? ref.watch(promptProvider(promptId))
        : const AsyncValue.data(null); // Watch only if isPrompt is true

    final SubmissionQueryParam queryParam = isPrompt
        ? (type: SubmissionQueryType.byPrompt, id: promptId, user: null)
        : (type: SubmissionQueryType.all, id: null, user: null);

    final submissionAsync = ref.watch(submissionNotifierProvider(queryParam));

    Future<void> refreshSubmissions() async {
      ref.invalidate(submissionNotifierProvider(queryParam));
      await ref.read(submissionNotifierProvider(queryParam).future);
    }

    // only show a submit button if we are on today's prompt
    Widget? fab;
    if (isPrompt) {
      fab = promptAsync.when(
          loading: () => null,
          error: (e, _) => null,
          data: (prompt) {
            if (prompt != null && isToday(prompt.date)) {
              return FloatingActionButton.extended(
                onPressed: () => Navigator.pushNamed(
                    context, "/submit_photo_screen",
                    arguments: prompt.id),
                label: Text("Submit Prompt"),
                icon: Icon(Icons.add),
              );
            } else {
              return null;
            }
          });
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
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomInset: false,
      body: submissionAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (submissions) {
          if (submissions.isEmpty) {
            return Center(child: Text("No submissions yet!"));
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
