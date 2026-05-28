import 'package:flutter/material.dart';
import 'package:jalan_aman/pages/map_page.dart';
import 'package:jalan_aman/pages/nearby_reports_page.dart';
import 'package:jalan_aman/pages/profile_page.dart';
import 'package:jalan_aman/pages/report_page.dart';
import 'package:jalan_aman/theme/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 1;

  final List<Widget> _pages = const [
    NearbyReportsPage(),
    MapPage(),
    MyReportsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: _BottomNav(
        currentIndex: currentIndex,
        onTap: (value) => setState(() {
          currentIndex = value;
        }),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: AppColors.shadowColor,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.travel_explore_outlined),
          selectedIcon: Icon(Icons.travel_explore_rounded, color: Colors.white),
          label: 'Nearby',
        ),
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map_rounded, color: Colors.white),
          label: "Map",
        ),
        NavigationDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt_rounded, color: Colors.white),
          label: 'Mine',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded, color: Colors.white),
          label: 'Profile',
        ),
      ],
    );
  }
}
