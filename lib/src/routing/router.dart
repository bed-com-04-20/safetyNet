import 'package:flutter/material.dart';
import 'package:safetynet/src/ui/report_form_screen.dart';
import 'package:safetynet/src/ui/report_list_screen.dart';
import '../ui/home.dart';

class AppRouter extends StatefulWidget {
  @override
  _AppRouterState createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    ReportFormScreen(),
    ReportListScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Report Missing Person',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search missing Person',
          ),
        ],
      ),
    );
  }
}
