import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/models/user_model.dart';
import 'package:picture_that/providers/relationship_provider.dart';
import 'package:picture_that/screens/tabs/profile_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/widgets/custom_button.dart';
import 'package:picture_that/widgets/custom_skeletonizer.dart';
import 'package:picture_that/widgets/custom_text_input.dart';
import 'package:picture_that/widgets/empty_state.dart';
import 'package:picture_that/widgets/custom_image.dart';

final searchResultListSkeleton = CustomSkeletonizer(
  child: ListView.builder(
    itemCount: 10,
    itemBuilder: (context, index) => SearchResultItem(
      user: getDummyUserSearchResult(index: index),
    ),
  ),
);

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<UserSearchResultModel> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _isLoading = false;
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().isNotEmpty) {
        _performSearch(value.trim());
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);

    try {
      final results = await searchUsers(query: query);

      setState(() => _searchResults = results);
    } catch (e) {
      customShowSnackbar(e);
      if (mounted) setState(() => _searchResults = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: CustomTextInput(
          controller: _searchController,
          hintText: "Search for users...",
          onChanged: (value) => _onSearchChanged(value),
          autocorrect: false,
          autofocus: true,
          leadingButton: IconButton(
            onPressed: navigateBack,
            icon: const Icon(Icons.arrow_back),
          ),
          trailingButton: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _clearSearch(),
                )
              : null,
        ),
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) return searchResultListSkeleton;

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return EmptyState(
        title: 'No results for "${_searchController.text}"',
        icon: Icons.person_off,
        subtitle: "Try a different username",
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isEmpty) {
      return EmptyState(
        title: "Find Users",
        icon: Icons.search,
        subtitle: "Search for users by their username",
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return SearchResultItem(user: _searchResults[index]);
      },
    );
  }
}

class SearchResultItem extends ConsumerWidget {
  final UserSearchResultModel user;

  const SearchResultItem({
    required this.user,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ensures widget is rebuilt when user is followed or
    ref.watch(relationshipProvider);
    final relationshipNotifier = ref.watch(relationshipProvider.notifier);
    final isFollowing = relationshipNotifier.isFollowing(user.uid);
    final isFollower = relationshipNotifier.isFollower(user.uid);
    final isSelf = user.uid == auth.currentUser?.uid;

    return ListTile(
      leading: CustomImage(
        key: ValueKey(user.uid),
        imageProvider: NetworkImage(user.profileImageUrl),
        shape: CustomImageShape.circle,
        width: 40,
        height: 40,
      ),
      trailing: isSelf
          ? null
          : SizedBox(
              width: 130,
              child: CustomButton(
                label: isFollowing
                    ? "Unfollow"
                    : "Follow${isFollower ? " back" : ""}",
                onPressed: () => toggleFollow(context, ref, user.uid),
                type: isFollowing
                    ? CustomButtonType.outlined
                    : CustomButtonType.filled,
              ),
            ),
      title: Text("${user.firstName} ${user.lastName}"),
      subtitle: Text("@${user.username}"),
      onTap: () => navigate(ProfileScreen(userId: user.uid)),
    );
  }
}
