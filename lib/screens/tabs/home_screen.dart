import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/providers/notification_badge_provider.dart';
import 'package:picture_that/providers/relationship_provider.dart';
import 'package:picture_that/screens/tabs/feed_screen.dart';
import 'package:picture_that/screens/tabs/profile_screen.dart';
import 'package:picture_that/screens/tabs/prompts_screen.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  int _currentIndex = 0;
  PageController? _pageController;

  final List<Widget> _views = [
    PromptsScreen(),
    FeedScreen(),
    ProfileScreen(userId: auth.currentUser?.uid),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // initialize relationship_provider
    ref.read(relationshipProvider);
  }

  @override
  Widget build(BuildContext context) {
    final notificationsStreamAsync = ref.watch(hasUnseenNotificationsProvider);

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
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.lightbulb),
            label: "Prompts",
          ),
          NavigationDestination(
            icon: Icon(Icons.image),
            label: "Feed",
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: notificationsStreamAsync.value ?? false,
              smallSize: 10.0,
              child: Icon(Icons.person),
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
