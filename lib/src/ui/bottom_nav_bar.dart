import 'package:flutter/material.dart';
import 'package:safetynet/src/ui/home.dart';
import 'package:safetynet/src/ui/report_form_screen.dart';

import 'Admin/admin_crime_report_screen.dart'; // Assuming this is your "Report missing person" screen

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
      onTap: (index) {
        onTabTapped(index);

        // Handle navigation based on selected tab index
        if (index == 1) {
          // Navigate to the "Report missing person" screen (or similar)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportFormScreen()),
          );
        } else if (index == 2) {
          // Navigate to the "Report crime" screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminCrimeReportScreen()),
          );
        }
      },
      currentIndex: currentIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white60,
      backgroundColor: Colors.transparent,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Report missing person',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.report),
          label: 'Report crime',
        ),
      ],
    );
  }
}
