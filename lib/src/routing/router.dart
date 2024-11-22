import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:safetynet/src/ui/crime_report_form_screen.dart';
import '../ui/home.dart';
import '../ui/report_form_screen.dart';
import '../ui/notifications.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  _AppRouterState createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  int _currentIndex = 0;
  int _unreadNotificationCount = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ReportFormScreen(),
    CrimeReportFormScreen(),
  ];

  // Listen for unread notifications from Firebase
  void _listenForUnreadNotifications() {
    FirebaseDatabase.instance
        .ref('notifications/user1')
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        int unreadCount = 0;
        data.forEach((key, value) {
          if (value['read'] == false) {
            unreadCount++;
          }
        });

        setState(() {
          _unreadNotificationCount = unreadCount;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _listenForUnreadNotifications();
  }

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
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF0A0933),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BottomNavigationBar(
                  onTap: onTabTapped,
                  currentIndex: _currentIndex,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white60,
                  backgroundColor: Colors.transparent,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),

                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Report missing person',
                    ),

                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Report crime',
                    ),
                  ]
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
