import 'package:flutter/material.dart';
import 'package:picturethat/screens/authenticated/feed_screen.dart';
import 'package:picturethat/screens/authenticated/profile_screen.dart';
import 'package:picturethat/screens/authenticated/prompts_screen.dart';
import 'package:picturethat/screens/authenticated/search_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    PromptsScreen(),
    FeedScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _views[_currentIndex],
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.transparent,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.lightbulb),
            label: "Prompts",
          ),
          NavigationDestination(
            icon: Icon(Icons.image),
            label: "Feed",
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
