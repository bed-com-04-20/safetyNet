import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safetynet/reusable_widgets/reusable_widgets.dart';
import 'package:safetynet/utils/colors_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Add logic for the `_crimes` function
  void _crimes() async {
    // Logic for crimes or navigation goes here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Crimes and Missing People"),
        backgroundColor: const Color(0xFF0A0933), // Match background
      ),
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: hexStringToColor("615EFC"),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).size.height * 0.2,
            20,
            0,
          ),
          child: Column(
            children: <Widget>[
              logoWidget("assets/images/logo.png"),
              const SizedBox(height: 30),
              signInSignUpButton(
                context,
                false,
                _crimes,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
