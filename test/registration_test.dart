import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safetynet/src/ui/.dart';
import 'package:safetynet/src/ui/Home.dart';
import 'package:safetynet/src/ui/signUp.dart';

void main() {
  group('Registration Page Tests', () {
    testWidgets('Check if all widgets are present', (WidgetTester tester) async {
      // Load RegistrationPage
      await tester.pumpWidget(
        MaterialApp(
          home: RegistrationPage(),
        ),
      );
      // Check for logo widget
      expect(find.byType(Image), findsOneWidget);

      // Check for email text field
      expect(find.widgetWithText(TextField, "Enter username"), findsOneWidget);

      // Check for password text field
      expect(find.widgetWithText(TextField, "Enter Password"), findsOneWidget);

      // Check for sign-in button
      expect(find.text("SIGN IN"), findsOneWidget);

      // Check for sign-up option
      expect(find.text("Don't have account?"), findsOneWidget);
      expect(find.text("Sign UP"), findsOneWidget);
    });

    testWidgets('Navigation to HomePage on sign-in button press', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegistrationPage(),
        ),
      );
      // Simulate entering text in the email and password fields
      await tester.enterText(find.widgetWithText(TextField, "Enter username"), "testuser");
      await tester.enterText(find.widgetWithText(TextField, "Enter Password"), "password123");

      // Tap on the sign-in button
      await tester.tap(find.text("SIGN IN"));
      await tester.pumpAndSettle();

      // Verify navigation to HomePage
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Navigation to SignUpScreen on sign-up link tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegistrationPage(),
        ),
      );

      // Tap on the "Sign UP" link
      await tester.tap(find.text("Sign UP"));
      await tester.pumpAndSettle();

      // Verify navigation to SignUpScreen
      expect(find.byType(SignUpScreen), findsOneWidget);
    });
  });
}
