import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/models/prompt_model.dart';
import 'package:picturethat/providers/auth_provider.dart';

final promptProvider =
    FutureProvider.family<PromptModel?, String>((ref, promptId) async {
  // ensures auth state is loaded, will reset all state when auth changes
  ref.watch(authProvider);

  final prompt = await getPrompt(promptId: promptId);

  return prompt;
});

final promptsProvider = FutureProvider<List<PromptModel>>((ref) async {
  // ensures auth state is loaded, will reset all state when auth changes
  ref.watch(authProvider);

  return await getPrompts();
});
