import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File type
import 'package:firebase_database/firebase_database.dart';
import '../../models/report_model.dart';
import '../../utils/colors_utils.dart';
import '../../utils/validators.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference reportsRef = FirebaseDatabase.instance.ref().child('missing_person_reports');
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

  // Loading state
  bool _isLoading = false;

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
          .child('missing_persons/${DateTime.now()}.jpg');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  // Check for duplicate report details
  Future<bool> _checkForDuplicateReport() async {
    final snapshot = await reportsRef.once();
    if (snapshot.snapshot.value != null) {
      final reportsMap = snapshot.snapshot.value as Map<dynamic, dynamic>?;
      if (reportsMap != null) {
        for (var report in reportsMap.values) {
          if (report is Map<dynamic, dynamic> && report.containsKey('details')) {
            if (report['details'] == details) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  // Submit the form to Realtime Database
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

      // Create a new report using the ReportModel
      ReportModel newReport = ReportModel(
        missingPersonName: missingPersonName,
        age: age,
        gender: gender,
        lastSeen: _selectedDate != null ? _dateFormatter.format(_selectedDate!) : '',
        location: location,
        details: details,
        imageUrl: _imageUrl,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      try {
        // Push the new report to Firebase Realtime Database
        await reportsRef.push().set(newReport.toJson()).then((_) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Report Submitted"),
              content: Text("The missing person report has been successfully submitted."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _formKey.currentState!.reset();
                    _selectedImage = null;
                  },
                  child: Text("OK"),
                ),
              ],
            ),
          );
        });
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
          color: hexStringToColor("615EFC"),
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
                    hintText: 'Enter a name of a missing person',
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
                    hintText: 'Provide where s/he was lastly seen',
                  ),
                  validator: Validators.requiredField,
                  onSaved: (value) {
                    location = value!;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Details',
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    hintText: 'Enter additional details',
                  ),
                  validator: Validators.requiredField,
                  onSaved: (value) {
                    details = value!;
                  },
                ),
                SizedBox(height: 16.0),
                if (_selectedImage != null)
                  Image.file(_selectedImage!, height: 200, fit: BoxFit.cover), // Show selected image
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text("Pick an Image"),
                ),
                SizedBox(height: 16.0),
                if (_isLoading)
                  Center(child: CircularProgressIndicator()), // Show loading indicator
                ElevatedButton(
                  onPressed: submitReport,
                  child: Text("Submit Report"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
