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

  // Focus nodes for managing field navigation
  final FocusNode _streetFocusNode = FocusNode();
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _detailsFocusNode = FocusNode();

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
            title: const Text("Report Submitted"),
            content: const Text("The crime report has been successfully submitted."),
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
  void dispose() {
    // Dispose focus nodes to avoid memory leaks
    _streetFocusNode.dispose();
    _cityFocusNode.dispose();
    _detailsFocusNode.dispose();
    super.dispose();
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
                validator: (value) => value!.isEmpty ? 'Please enter a street' : null,
                onSaved: (value) {
                  street = value!;
                },
              ),
              const SizedBox(height: 16.0),
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
                validator: (value) => value!.isEmpty ? 'Please enter a city' : null,
                onSaved: (value) {
                  city = value!;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                focusNode: _detailsFocusNode,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Crime Details',
                  labelStyle: TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                  hintText: 'Enter the details',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                maxLines: 4,
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
