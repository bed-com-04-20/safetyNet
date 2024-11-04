import 'package:flutter/material.dart';
import 'package:safetynet/reusable_widgets/reusable_widgets.dart';
import 'package:safetynet/src/routing/router.dart';
import 'package:safetynet/src/ui/signUp.dart';
import 'package:safetynet/utils/colors_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: hexStringToColor("615EFC"),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                logoWidget("assets/logo.png"),
                SizedBox(height: 30),
                reusableTextField("Enter username", Icons.person_outline, false, _emailTextController),
                SizedBox(height: 30),
                reusableTextField("Enter Password", Icons.lock_outline, true, _passwordTextController),
                SizedBox(height: 30),

                signInSignUpButton(context, true, () async {
                  // Firebase authentication login
                  try {
                    final userCredential = await _auth.signInWithEmailAndPassword(
                      email: _emailTextController.text.trim(),
                      password: _passwordTextController.text.trim(),
                    );

                    if (userCredential.user != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AppRouter()));
                    }
                  } catch (e) {
                    // Show error message if login fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Login failed: ${e.toString()}")),
                    );
                  }
                }),

                signUpOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
