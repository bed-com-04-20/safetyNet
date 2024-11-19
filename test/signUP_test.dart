import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safetynet/lib/ui/signUp.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Mock classes for FirebaseAuth and FirebaseDatabase
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockDatabaseReference extends Mock implements DatabaseReference {}

void main() {
  group('SignUp Tests', () {
    late MockFirebaseAuth mockAuth;
    late MockDatabaseReference mockDatabase;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockDatabase = MockDatabaseReference();
    });

    group('Input Validation', () {
      testWidgets('Empty username field shows error', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: SignUpScreen()));

        final signUpButton = find.text('Sign Up');
        await tester.tap(signUpButton);
        await tester.pump();

        expect(find.text('Username is required'), findsOneWidget);
      });

      testWidgets('Valid username does not show error', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: SignUpScreen()));

        final usernameField = find.byType(TextFormField).at(0);
        await tester.enterText(usernameField, 'testuser');

        final signUpButton = find.text('Sign Up');
        await tester.tap(signUpButton);
        await tester.pump();

        expect(find.text('Username is required'), findsNothing);
      });

      testWidgets('Empty email field shows error', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: SignUpScreen()));

        final signUpButton = find.text('Sign Up');
        await tester.tap(signUpButton);
        await tester.pump();

        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('Invalid email format shows error', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: SignUpScreen()));

        final emailField = find.byType(TextFormField).at(1);
        await tester.enterText(emailField, 'test');

        final signUpButton = find.text('Sign Up');
        await tester.tap(signUpButton);
        await tester.pump();

        expect(find.text('Enter a valid email'), findsOneWidget);
      });

      testWidgets('Empty password field shows error', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: SignUpScreen()));

        final signUpButton = find.text('Sign Up');
        await tester.tap(signUpButton);
        await tester.pump();

        expect(find.text('Password is required'), findsOneWidget);
      });

      testWidgets('Password too short shows error', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: SignUpScreen()));

        final passwordField = find.byType(TextFormField).at(2);
        await tester.enterText(passwordField, '12345');

        final signUpButton = find.text('Sign Up');
        await tester.tap(signUpButton);
        await tester.pump();

        expect(find.text('Password must be at least 8 characters long'), findsOneWidget);
      });
    });

    group('Firebase Interaction', () {
      testWidgets('Successful registration navigates to login screen', (WidgetTester tester) async {
        // Mock the successful registration response
        when(mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => MockUserCredential());

        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) {
              return SignUpScreen();
            },
          ),
          routes: {'login_screen': (_) => Scaffold(body: Text('Login Screen'))},
        ));

        final usernameField = find.byType(TextFormField).at(0);
        final emailField = find.byType(TextFormField).at(1);
        final passwordField = find.byType(TextFormField).at(2);
        final signUpButton = find.text('Sign Up');

        await tester.enterText(usernameField, 'testuser');
        await tester.enterText(emailField, 'test@example.com');
        await tester.enterText(passwordField, 'password123');
        await tester.tap(signUpButton);
        await tester.pumpAndSettle();

        expect(find.text('Login Screen'), findsOneWidget);
      });

      testWidgets('Email already in use shows error', (WidgetTester tester) async {
        when(mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'The email address is already in use by another account.',
        ));

        await tester.pumpWidget(MaterialApp(home: SignUpScreen()));

        final emailField = find.byType(TextFormField).at(1);
        final passwordField = find.byType(TextFormField).at(2);
        final signUpButton = find.text('Sign Up');

        await tester.enterText(emailField, 'test@example.com');
        await tester.enterText(passwordField, 'password123');
        await tester.tap(signUpButton);
        await tester.pump();

        expect(find.text('The email address is already in use by another account.'), findsOneWidget);
      });
    });

    group('Loading Indicator', () {
      testWidgets('Spinner is visible during registration', (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: SignUpScreen()));

        final usernameField = find.byType(TextFormField).at(0);
        final emailField = find.byType(TextFormField).at(1);
        final passwordField = find.byType(TextFormField).at(2);
        final signUpButton = find.text('Sign Up');

        await tester.enterText(usernameField, 'testuser');
        await tester.enterText(emailField, 'test@example.com');
        await tester.enterText(passwordField, 'password123');
        await tester.tap(signUpButton);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });
  });
}
