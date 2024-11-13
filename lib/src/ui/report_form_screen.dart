import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/report_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/validators.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../reusable_widgets/reusable_widgets.dart'; // Import reusable widgets

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  File? _selectedImage;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  // Form fields
  String missingPersonName = '';
  String age = '';
  String gender = '';
  String lastSeen = '';
  String location = '';
  String details = '';

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

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

  Future<bool> _checkForDuplicateReport() async {
    final reportsCollection = FirebaseFirestore.instance.collection('missing_person_reports');
    final querySnapshot = await reportsCollection
        .where('details', isEqualTo: details)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> submitReport() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final isDuplicate = await _checkForDuplicateReport();
      if (isDuplicate) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Duplicate Report"),
            content: Text("A report with the same details has already been submitted."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

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
                  _selectedImage = null; // Reset selected image
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      } catch (error) {
        print("Error submitting report: $error");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Color(0xFF0A0933),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    hintText: 'Enter the name of the missing person',
                  ),
                  validator: Validators.requiredField,
                  onSaved: (value) {
                    missingPersonName = value!;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Age',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    hintText: 'Enter estimated age',
                  ),
                  validator: Validators.requiredField,
                  onSaved: (value) {
                    age = value!;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    hintText: 'Enter gender',
                  ),
                  validator: Validators.requiredField,
                  onSaved: (value) {
                    gender = value!;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Last Seen',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    hintText: 'Choose Date',
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
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                        _dateController.text = _dateFormatter.format(pickedDate);
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
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    hintText: 'Provide where the person was last seen',
                  ),
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
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 8.0),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Provide additional information to help find the person',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.white),
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                      maxLines: 4,
                      validator: Validators.requiredField,
                      onSaved: (value) {
                        details = value!;
                      },
                    ),
                  ],
                ),
                SizedBox(height: 45.0),

                // Image Picker button using reusableButton
                reusableButton(
                  context,
                  "Upload Image",
                  _pickImage,
                  icon: Icons.photo,
                ),

                // Display selected image (if any)
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

                SizedBox(height: 30.0),

                // Submit button using reusableButton
                reusableButton(
                  context,
                  "Submit Report",
                  (_isLoading ? null : submitReport) as Function,
                  icon: Icons.send,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
