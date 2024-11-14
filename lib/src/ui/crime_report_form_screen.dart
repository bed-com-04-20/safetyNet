import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/crime_report_model.dart';
import '../../services/firestore_service.dart';

class CrimeReportFormScreen extends StatefulWidget {
  const CrimeReportFormScreen({super.key});

  @override
  _CrimeReportFormScreenState createState() => _CrimeReportFormScreenState();
}

class _CrimeReportFormScreenState extends State<CrimeReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  File? _selectedImage;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  // Form fields
  String street = '';
  String city = '';
  String crimeDetails = '';

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Upload the image to Firebase Storage
  Future<String> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('crime_reports/${DateTime.now()}.jpg');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  // Submit the form to Firestore
  Future<void> submitCrimeReport() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // If an image is selected, upload it
      if (_selectedImage != null) {
        _imageUrl = await _uploadImage(_selectedImage!);
      }

      CrimeReportModel newCrimeReport = CrimeReportModel(
        street: street,
        city: city,
        crimeDetails: crimeDetails,
        imageUrl: _imageUrl,
        timestamp: DateTime.now(),
      );

      try {
        await _firestoreService.addCrimeReport(newCrimeReport);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Report Submitted"),
            content: Text("The crime report has been successfully submitted."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _formKey.currentState!.reset();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      } catch (error) {
        print("Error submitting crime report: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crime Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Street'),
                validator: (value) => value!.isEmpty ? 'Please enter a street' : null,
                onSaved: (value) {
                  street = value!;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) => value!.isEmpty ? 'Please enter a city' : null,
                onSaved: (value) {
                  city = value!;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Crime Details'),
                maxLines: 4,
                validator: (value) => value!.isEmpty ? 'Please enter crime details' : null,
                onSaved: (value) {
                  crimeDetails = value!;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.photo),
                label: Text("Select Photo"),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image.file(
                    _selectedImage!,
                    height: 200,
                  ),
                ),





              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: submitCrimeReport,
                child: Text('Submit Crime Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//julkgilo0goliiiuopoplkm