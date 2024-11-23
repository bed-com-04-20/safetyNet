import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:safetynet/models/report_model.dart';
import 'package:safetynet/screens/report_form_screen.dart';
import 'package:safetynet/services/firestore_service.dart';
import 'package:safetynet/utils/validators.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  // Set up test dependencies
  final mockFirestore = MockFirestoreInstance();
  final mockStorage = MockFirebaseStorage();
  final mockImagePicker = MockImagePicker();
  final firestoreService = FirestoreService(firestore: mockFirestore);

  group('Report Form Tests', () {
    testWidgets('Required fields should show validation errors',
            (WidgetTester tester) async {
          // Build the widget
          await tester.pumpWidget(
            MaterialApp(
              home: ReportFormScreen(),
            ),
          );

          // Tap the Submit button
          final submitButton = find.text('Submit Report');
          await tester.tap(submitButton);
          await tester.pump(); // Trigger a rebuild

          // Check for validation errors
          expect(find.text('This field is required'), findsNWidgets(5));
        });

    testWidgets('Should allow uploading an image and display it',
            (WidgetTester tester) async {
          // Mock an image file
          final testFile = File('path/to/test_image.jpg');

          when(mockImagePicker.pickImage(source: ImageSource.gallery))
              .thenAnswer((_) async => XFile(testFile.path));

          // Build the widget
          await tester.pumpWidget(
            MaterialApp(
              home: ReportFormScreen(),
            ),
          );

          // Tap the Upload Image button
          final uploadButton = find.text('Upload Image');
          await tester.tap(uploadButton);
          await tester.pump(); // Wait for the image picker action

          // Check if the image is displayed
          expect(find.byType(Image), findsOneWidget);
        });

    testWidgets('Firestore should save report correctly',
            (WidgetTester tester) async {
          // Build the widget
          await tester.pumpWidget(
            MaterialApp(
              home: ReportFormScreen(),
            ),
          );

          // Fill in the form
          await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Jane Doe');
          await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '30');
          await tester.enterText(find.widgetWithText(TextFormField, 'Gender'), 'Female');
          await tester.enterText(find.widgetWithText(TextFormField, 'Location'), 'Park');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Additional Details'),
              'Last seen jogging.');
          await tester.tap(find.widgetWithText(TextFormField, 'Last Seen'));
          await tester.pumpAndSettle();

          // Simulate selecting a date
          await tester.tap(find.text('20')); // Choose date
          await tester.pumpAndSettle();

          // Submit the form
          final submitButton = find.text('Submit Report');
          await tester.tap(submitButton);
          await tester.pumpAndSettle();

          // Verify the form was saved in Firestore
          final snapshot = await mockFirestore.collection('reports').get();
          expect(snapshot.docs.length, 1);
          expect(snapshot.docs.first.data()['missingPersonName'], 'Jane Doe');
        });

    test('Image should be resized before upload', () async {
      final testFile = File('path/to/large_image.jpg');

      Future<File> _resizeImage(File file) async {
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image == null) return file;

        final resized = img.copyResize(image, width: 800);
        return File(file.path)..writeAsBytesSync(img.encodeJpg(resized));
      }

      final resizedFile = await _resizeImage(testFile);

      expect(resizedFile.lengthSync() < testFile.lengthSync(), true);

      // Simulate upload
      final storageRef = mockStorage.ref().child('test_image.jpg');
      await storageRef.putFile(resizedFile);
      final url = await storageRef.getDownloadURL();

      expect(url, isNotNull);
    });

    testWidgets('User should see success dialog after form submission',
            (WidgetTester tester) async {
          // Build the widget
          await tester.pumpWidget(
            MaterialApp(
              home: ReportFormScreen(),
            ),
          );

          // Fill in the form
          await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'John Smith');
          await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '40');
          await tester.enterText(find.widgetWithText(TextFormField, 'Gender'), 'Male');
          await tester.enterText(find.widgetWithText(TextFormField, 'Location'), 'City Center');
          await tester.enterText(
              find.widgetWithText(TextFormField, 'Additional Details'),
              'Wearing a blue jacket.');
          await tester.tap(find.widgetWithText(TextFormField, 'Last Seen'));
          await tester.pumpAndSettle();

          // Simulate selecting a date
          await tester.tap(find.text('15'));
          await tester.pumpAndSettle();

          // Submit the form
          final submitButton = find.text('Submit Report');
          await tester.tap(submitButton);
          await tester.pumpAndSettle();

          // Verify success dialog
          expect(find.text('Report Submitted'), findsOneWidget);
        });
  });
}
