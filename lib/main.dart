import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/report_form_screen.dart';
import 'screens/report_list_screen.dart';
import 'screens/crime_report_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafetyNet App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(), // Set HomeScreen as the home widget
      routes: {
        '/reportForm': (context) => ReportFormScreen(),    // Route for Missing Person report form
        '/reportList': (context) => ReportListScreen(),    // Route for viewing report list
        '/crimeReport': (context) => CrimeReportFormScreen(), // Route for Crime report form
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> _screens = [
    ReportFormScreen(),      // Report Missing Person Screen
    ReportListScreen(),      // Report List Screen
    CrimeReportFormScreen(), // Report Crime Screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer after an item is tapped
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCD5C08),
      appBar: AppBar(
        title: Text('SAFETYNET'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              decoration: BoxDecoration(
                color: Color(0xFFCD5C08),
              ),
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Report Missing Person'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Report List'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text('Report Crime'),
              onTap: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex], // Display the selected screen
    );
  }
}
