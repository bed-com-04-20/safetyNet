import 'package:flutter/material.dart';
import 'package:safetynet/reusable_widgets/reusable_widgets.dart';
import 'package:safetynet/src/ui/replies.dart';
import 'package:safetynet/utils/colors_utils.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: hexStringToColor("615EFC"),
      ),

      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
        child: Column(
          children: <Widget>[
            logoWidget("assets/logo.png"),
            SizedBox(height: 30),

            signInSignUpButton(context, false, () {
            }),
            signInSignUpButton(context, false, () {
            }),

            signInSignUpButton(context, true, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ConversationScreen()));
            }),
          ],
        ),
      ),
    );
  }
}
