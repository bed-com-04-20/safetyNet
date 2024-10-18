import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File type
import 'package:firebase_storage/firebase_storage.dart'; // For file uploads
import '../models/report_model.dart';
import '../services/firestore_service.dart';
import '../utils/validators.dart';
import 'package:intl/intl.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  DateTime? _selectedDate;
  File? _selectedImage; // This will hold the selected image file
  String? _imageUrl; // This will store the image URL after upload
  final ImagePicker _picker = ImagePicker(); // To pick images

  // Form fields
  String missingPersonName = '';
  String age = '';
  String gender = '';
  String lastSeen = '';
  String location = '';
  String details = '';

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

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
      final storageRef = FirebaseStorage.instance.ref().child('missing_persons/${DateTime.now()}.jpg');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  // Submit the form to Firestore
  Future<void> submitReport() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // If an image is selected, upload it
      if (_selectedImage != null) {
        _imageUrl = await _uploadImage(_selectedImage!);
      }

      ReportModel newReport = ReportModel(
        missingPersonName: missingPersonName,
        age: age,
        gender: gender,
        lastSeen: lastSeen,
        location: location,
        details: details,
        imageUrl: _imageUrl, // Save the image URL
        timestamp: DateTime.now(),
      );

      try {
        await _firestoreService.addReport(newReport);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Report Submitted"),
            content: Text("The missing person report has been successfully submitted."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _formKey.currentState!.reset(); // Reset the form
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      } catch (error) {
        print("Error submitting report: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF615EFC),
      appBar: AppBar(
        title: Text('Report Missing Person'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Input for missing person name
              TextFormField(
                decoration: InputDecoration(labelText: 'Name',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    hintText: 'enter a name of a missing person'),
                validator: Validators.requiredField,
                onSaved: (value) {
                  missingPersonName = value!;
                },
              ),
              SizedBox(height: 16.0),

              // Input for missing person age
              TextFormField(
                decoration: InputDecoration(labelText: 'Age',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    hintText: 'Enter estamated age'),
                validator: Validators.requiredField,
                onSaved: (value) {
                  age = value!;
                },
              ),
              SizedBox(height: 16.0),

              // Input for missing person gender
              TextFormField(
                decoration: InputDecoration(labelText: 'Gender',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    hintText: 'Enter gender'),
                validator: Validators.requiredField,
                onSaved: (value) {
                  gender = value!;
                },
              ),
              SizedBox(height: 16.0),

              // Date Picker for Last Seen
              TextFormField(
                decoration: InputDecoration(labelText: 'Last Seen',
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  hintText: _selectedDate == null
                      ? 'Choose Date'
                      : _dateFormatter.format(_selectedDate!),
                ),
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'Please choose a date';
                  }
                  return null;
                },
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null && pickedDate != _selectedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                readOnly: true,
                onSaved: (value) {
                  if (_selectedDate != null) {
                    lastSeen = _dateFormatter.format(_selectedDate!);
                  }
                },
              ),
              SizedBox(height: 16.0),

              // Input for location
              TextFormField(
                decoration: InputDecoration(labelText: 'Location',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    hintText: 'Provide where s/he was lastly seen'),
                validator: Validators.requiredField,
                onSaved: (value) {
                  location = value!;
                },
              ),
              SizedBox(height: 16.0),


              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 8.0), // Space between label and TextField
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Provide any additional information that will help to find the person',
                      border: OutlineInputBorder(), // Rectangular border
                      contentPadding: EdgeInsets.all(16.0), // Padding inside the TextField
                    ),
                    maxLines: 4, // Allows the user to write multiple lines
                    validator: Validators.requiredField,
                    onSaved: (value) {
                      details = value!;
                    },
                  ),
                ],
              ),


              SizedBox(height: 45.0),

              // Image Picker button
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.photo), // Customize icon color
                label: Text(
                  "Upload image", style: TextStyle(), // Customize text color
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Color(0xFFCD5C08), // Background color
                  foregroundColor: Colors.white, // Ripple effect color when pressed
                  elevation: 5, // Elevation (shadow)
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12), // Padding inside button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                ),
              ),


              // Display selected image (if any)
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image.file(
                    _selectedImage!,
                    height: 200,
                  ),
                ),
              SizedBox(height: 16.0),

              // Submit button
              ElevatedButton(
                onPressed: submitReport,
                child: Text('Submit Report', style: TextStyle(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Color(0xFFCD5C08), // Background color
                  foregroundColor: Colors.white, // Ripple effect color when pressed
                  elevation: 5, // Elevation (shadow)
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12), // Padding inside button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
