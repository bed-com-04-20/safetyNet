import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/crime_report_model.dart';
import '../../services/firestore_service.dart';
import '../../reusable_widgets/reusable_widgets.dart';

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
  String crimeTitle = ''; // New field for Crime Title

  // Focus nodes for managing field navigation
  final FocusNode _streetFocusNode = FocusNode();
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _detailsFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode(); // New FocusNode for CrimeTitle

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Upload the selected image to Firebase Storage
  Future<String?> _uploadImage(File image) async {
    try {
      // Create a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('crime_reports/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the file to Firebase Storage
      await storageRef.putFile(image);

      // Get the download URL after the upload is complete
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
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
        crimeTitle: crimeTitle, // Add the CrimeTitle here
        street: street,
        city: city,
        crimeDetails: crimeDetails,
        imageUrl: _imageUrl,
        timestamp: DateTime.now(),
        status: 'pending', // Report status is set to pending for admin approval
      );

      try {
        await _firestoreService.addCrimeReport(newCrimeReport);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Report Submitted"),
            content: const Text("The crime report has been successfully submitted and is awaiting approval from an admin."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _formKey.currentState!.reset();
                },
                child: const Text("OK"),
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
      appBar: AppBar(
        title: const Text('Crime report'),
        backgroundColor: const Color(0xFF0A0933),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF0A0933),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // CrimeTitle TextFormField
              TextFormField(
                focusNode: _titleFocusNode,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_streetFocusNode);
                },
                decoration: const InputDecoration(
                  labelText: 'Crime Title',
                  labelStyle: TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                  hintText: 'Enter the title of the crime',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white), // Ensuring text is white
                validator: (value) => value!.isEmpty ? 'Please enter a crime title' : null,
                onSaved: (value) {
                  crimeTitle = value!;
                },
              ),
              const SizedBox(height: 16.0),
              // Street TextFormField
              TextFormField(
                focusNode: _streetFocusNode,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_cityFocusNode);
                },
                decoration: const InputDecoration(
                  labelText: 'Street',
                  labelStyle: TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                  hintText: 'Enter the street name',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white), // Ensuring text is white
                validator: (value) => value!.isEmpty ? 'Please enter a street' : null,
                onSaved: (value) {
                  street = value!;
                },
              ),
              const SizedBox(height: 16.0),
              // City TextFormField
              TextFormField(
                focusNode: _cityFocusNode,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_detailsFocusNode);
                },
                decoration: const InputDecoration(
                  labelText: 'City',
                  labelStyle: TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                  hintText: 'Enter the city name',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white), // Ensuring text is white
                validator: (value) => value!.isEmpty ? 'Please enter a city' : null,
                onSaved: (value) {
                  city = value!;
                },
              ),
              const SizedBox(height: 16.0),
              // Crime Details TextFormField
              TextFormField(
                focusNode: _detailsFocusNode,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  submitCrimeReport();
                },
                decoration: const InputDecoration(
                  labelText: 'Crime Details',
                  labelStyle: TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                  hintText: 'Provide details of the crime',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white), // Ensuring text is white
                validator: (value) => value!.isEmpty ? 'Please enter crime details' : null,
                onSaved: (value) {
                  crimeDetails = value!;
                },
              ),
              const SizedBox(height: 16.0),
              reusableButton(
                context,
                "Upload Image",
                _pickImage,
                icon: Icons.photo,
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image.file(
                    _selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 30.0),
              reusableButton(
                context,
                "Submit Crime",
                submitCrimeReport,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
