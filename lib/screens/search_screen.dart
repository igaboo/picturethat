import 'dart:async';

import 'package:flutter/material.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/models/user_model.dart';
import 'package:picture_that/utils/handle_error.dart';
import 'package:picture_that/utils/navigate.dart';
import 'package:picture_that/widgets/custom_skeletonizer.dart';
import 'package:picture_that/widgets/empty_state.dart';
import 'package:picture_that/widgets/custom_image.dart';

final skeleton = CustomSkeletonizer(
  child: ListView.builder(
    itemCount: 10,
    itemBuilder: (context, index) => SearchResultItem(
        user: UserSearchResultModel(
      uid: "skeleton",
      firstName: "skeleton",
      lastName: "skeleton",
      username: "skeleton",
      profileImageUrl: "https://dummyimage.com/1x1/0011ff/0011ff.png",
    )),
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

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.trim().isNotEmpty) {
        _performSearch(_searchController.text.trim());
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

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) handleError(context, e);
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(150.0), // Rounded corners
            ),
            child: Row(
              children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back)),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: "Search for users...",
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => _onSearchChanged(),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _clearSearch(),
                  ),
              ],
            ),
          ),
        ),
        body: _buildSearchResults());
  }

  Widget _buildSearchResults() {
    if (_isLoading) return skeleton;

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

class SearchResultItem extends StatelessWidget {
  final UserSearchResultModel user;

  const SearchResultItem({
    required this.user,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CustomImage(
        key: ValueKey(user.uid),
        imageProvider: NetworkImage(user.profileImageUrl),
        shape: CustomImageShape.circle,
        width: 40,
        height: 40,
      ),
      title: Text("${user.firstName} ${user.lastName}"),
      subtitle: Text("@${user.username}"),
      onTap: () => navigate(
        context,
        "/profile_screen",
        arguments: user.uid,
      ),
    );
  }
}
