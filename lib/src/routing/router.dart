import 'package:flutter/material.dart';
import 'package:safetynet/src/ui/report_list_screen.dart';
import '../ui/home.dart';
import '../ui/report_form_screen.dart';

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
      body: Stack(
        children: [
          _pages[_currentIndex],

          // Floating Bottom Navigation Bar
          Positioned(
            left: 30,
            right: 30,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF0A0933),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 4), // Shadow position
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BottomNavigationBar(
                  onTap: onTabTapped,
                  currentIndex: _currentIndex,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white60,
                  backgroundColor: Colors.transparent,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Report missing person',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.list),
                      label: 'Missing persons',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
