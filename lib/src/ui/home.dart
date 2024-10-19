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

  void _crimes() async{}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(

          color: hexStringToColor("615EFC"),
        ),

        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
          child: Column(
            children: <Widget>[
              logoWidget("assets/images/logo.png"),
              SizedBox(height: 30),

              signInSignUpButton(context,
                  false,
                  _crimes)



            ],
          ),
        ),
      ),
    );
  }
}
