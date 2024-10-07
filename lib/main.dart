import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/report_form_screen.dart';
import 'screens/report_list_screen.dart';


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
      title: 'Missing Person Report',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReportListScreen(), // Navigate to report form screen
      routes: {
        '/reportForm': (context) => ReportFormScreen(), // Define a route for the report form
        '/reportList': (context) => ReportListScreen(), // Define a route for the report list
      },
    );
  }
}

