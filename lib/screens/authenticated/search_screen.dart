import 'dart:async';

import 'package:flutter/material.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/models/user_model.dart';
import 'package:picturethat/utils/handle_error.dart';
import 'package:picturethat/widgets/custom_image.dart';
import 'package:picturethat/widgets/empty_state.dart';

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
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

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
        final user = _searchResults[index];
        return ListTile(
          leading: CustomNetworkImage(
            url: user.profileImageUrl,
            width: 40,
            height: 40,
            borderRadius: 60,
          ),
          title: Text("${user.firstName} ${user.lastName}"),
          subtitle: Text("@${user.username}"),
          onTap: () => Navigator.pushNamed(
            context,
            "/profile_screen",
            arguments: user.uid,
          ),
        );
      },
    );
  }
}
