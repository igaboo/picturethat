import 'package:flutter/material.dart';
import 'package:picture_that/screens/tabs/feed_screen.dart';
import 'package:picture_that/screens/tabs/profile_screen.dart';
import 'package:picture_that/screens/tabs/prompts_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  PageController? _pageController;

  final List<Widget> _views = [
    PromptsScreen(),
    FeedScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _views,
      ),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.transparent,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
            _pageController?.jumpToPage(index);
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
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
