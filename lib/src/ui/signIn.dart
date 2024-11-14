import 'package:flutter/material.dart';
import 'package:safetynet/reusable_widgets/reusable_widgets.dart';
import 'package:safetynet/src/routing/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetynet/src/ui/signUp.dart';
import 'package:firebase_database/firebase_database.dart';
import 'admins_approval.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Color(0xFF0A0933),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                logoWidget("assets/logo.png"),
                SizedBox(height: 30),
                reusableTextField("Enter Email", Icons.email_outlined, false, _emailTextController),
                SizedBox(height: 30),
                reusableTextField("Enter Password", Icons.lock_outline, true, _passwordTextController),
                SizedBox(height: 30),

                // Sign-In Button with Role Check
                reusableButton(context, 'SIGN IN', () async {
                  try {
                    final userCredential = await _auth.signInWithEmailAndPassword(
                      email: _emailTextController.text.trim(),
                      password: _passwordTextController.text.trim(),
                    );

                    if (userCredential.user != null) {
                      // Access the Realtime Database and check the user's role
                      final DatabaseReference userRef = FirebaseDatabase.instance
                          .ref()
                          .child('users')
                          .child(userCredential.user!.uid);

                      userRef.once().then((DatabaseEvent event) {
                        final snapshot = event.snapshot;
                        if (snapshot.exists) {
                          final data = snapshot.value as Map<dynamic, dynamic>?;
                          final role = data?['role'];
                          print("User role fetched from Realtime Database: $role");

                          if (role == 'admin') {
                            // Navigate to ImageManagementPage if user is an admin
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => AdminReportScreen()),
                            );
                          } else {
                            // Navigate to a regular user page if not an admin
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => AppRouter()),
                            );
                          }
                        } else {
                          print("User document does not exist in Realtime Database.");
                        }
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Sign-In failed: ${e.toString()}")),
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
