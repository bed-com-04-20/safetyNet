import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTabTapped;
  final int unreadNotificationCount;

  const BottomNavBar({
    Key? key,
    required this.onTabTapped,
    required this.currentIndex,
    required this.unreadNotificationCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: onTabTapped,
      currentIndex: currentIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white60,
      backgroundColor: Colors.transparent,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: 'Report missing person',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.report),
          label: 'Report crime',
        ),
      ],
    );
  }
}
