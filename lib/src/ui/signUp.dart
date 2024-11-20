import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetynet/reusable_widgets/reusable_widgets.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
          print('User created with UID: ${user.uid}');

          await _database.child('users').child(user.uid).set({
            'username': username,
            'email': email,
          });

          print('User data stored in database for UID: ${user.uid}');

          // Navigate to the login screen
          Navigator.pushNamed(context, 'login_screen');
        } else {
          print('User is null, could not register.');
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      } finally {
        setState(() {
          showSpinner = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Color(0xFF0A0933),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                logoWidget("assets/logo.png"),
                SizedBox(height: 30),

                reusableTextField(
                  'Enter your username',
                  Icons.person_outline,
                  false,
                  _usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),

                reusableTextField(
                  'Enter your email',
                  Icons.email_outlined,
                  false,
                  _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),

                reusableTextField(
                  'Enter your password',
                  Icons.lock_outline,
                  true,
                  _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),

                // Use the reusableButton for "SIGN UP"
                reusableButton(context, 'SIGN UP', _register),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
