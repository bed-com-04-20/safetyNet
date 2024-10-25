import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetynet/reusable_widgets/reusable_widgets.dart';
import 'package:safetynet/utils/colors_utils.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Create a reference to the database
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance

  bool showSpinner = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        showSpinner = true;
      });

      String username = _usernameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? user = userCredential.user;

        if (user != null) {
          await _database.child('users').child(user.uid).set({
            'username': username,
            'email': email,
          });

          print('User registered: $username');

          Navigator.pushNamed(context, 'login_screen');
        }
      } catch (e) {
        print('Error: $e');
      }

      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: hexStringToColor("615EFC"),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo.png"),
                SizedBox(height: 30),

                reusableTextField(
                  'Enter your username',
                  Icons.person_outline,
                  false,
                  _usernameController,
                ),
                SizedBox(height: 30),

                reusableTextField(
                  'Enter your email',
                  Icons.email_outlined,
                  false,
                  _emailController,
                ),
                SizedBox(height: 30),

                reusableTextField(
                  'Enter your password',
                  Icons.lock_outline,
                  true,
                  _passwordController,
                ),
                SizedBox(height: 30),

                signInSignUpButton(
                  context,
                  false,
                  _register,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
