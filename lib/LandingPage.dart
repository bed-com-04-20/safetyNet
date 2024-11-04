import 'package:flutter/material.dart';

void main() {
  runApp(CrimeReporterApp());
}

class CrimeReporterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 50,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 2,
                  ),
                  children: [
                    TextSpan(text: 'Welcome'),
                    WidgetSpan(
                      child: SizedBox(width: 20),
                    ),
                    TextSpan(text: 'to'),
                    WidgetSpan(
                      child: SizedBox(width: 4),
                    ),
                    TextSpan(text: 'SafetyNet,'),
                    WidgetSpan(
                      child: SizedBox(width: 4),
                    ),
                    TextSpan(text: 'where'),
                    WidgetSpan(
                      child: SizedBox(width: 4),
                    ),
                    TextSpan(text: 'Hope'),
                    WidgetSpan(
                      child: SizedBox(width: 20),
                    ),
                    TextSpan(text: 'meets'),
                    WidgetSpan(
                      child: SizedBox(width: 4),
                    ),
                    TextSpan(text: 'Action!'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
