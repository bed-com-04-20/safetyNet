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
import 'package:image/image.dart' as img; // For image resizing

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
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        print('Image selected: ${pickedFile.path}');
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Image Selection Failed"),
          content: const Text("An error occurred while selecting the image. Please try again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Future<File> _resizeImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return file;

      final resized = img.copyResize(image, width: 800); // Resize to 800px width

      final resizedFile = File(file.path)..writeAsBytesSync(img.encodeJpg(resized));
      print('Image resized');
      return resizedFile;
    } catch (e) {
      print('Error resizing image: $e');
      return file; // Return original if resizing fails
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      final resizedImage = await _resizeImage(image);
      final storageRef = FirebaseStorage.instance.ref().child('missing_persons/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(resizedImage);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Upload state: ${snapshot.state}');
        print('Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
      }, onError: (e) {
        print('Upload error: $e');
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Error uploading image: $e');
    }
  }

  Future<bool> _checkForDuplicateReport() async {
    try {
      final reportsCollection = FirebaseFirestore.instance.collection('missing_person_reports');
      final querySnapshot = await reportsCollection.where('details', isEqualTo: details).get();
      print('Duplicate check: ${querySnapshot.docs.isNotEmpty}');
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking duplicate report: $e');
      // Optionally, show an error dialog here
      return false;
    }
  }

  Future<void> submitReport() async {
    print('Starting report submission...');
    if (_formKey.currentState!.validate()) {
      print('Form is valid');
      _formKey.currentState!.save();

      print('Checking for duplicates...');
      final isDuplicate = await _checkForDuplicateReport();
      print('Duplicate check result: $isDuplicate');

      if (isDuplicate) {
        print('Duplicate report found');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Duplicate Report"),
            content: const Text("A report with the same details has already been submitted."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });
      print('Loading state set to true');

      try {
        if (_selectedImage != null) {
          print('Uploading image...');
          _imageUrl = await _uploadImage(_selectedImage!);
          print('Image uploaded, URL: $_imageUrl');
        } else {
          print('No image selected');
        }

        ReportModel newReport = ReportModel(
          missingPersonName: missingPersonName,
          age: age,
          gender: gender,
          lastSeen: lastSeen,
          location: location,
          details: details,
          imageUrl: _imageUrl,
          timestamp: DateTime.now(),
          status: "submitted",
          isApproved: false,
        );

        print('Adding report to Firestore...');
        await _firestoreService.addReport(newReport);
        print('Report added successfully');

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Report Submitted"),
            content: const Text("The missing person report has been successfully submitted."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _formKey.currentState!.reset();
                  setState(() {
                    _selectedImage = null;
                    _dateController.text = '';
                  });
                  print('Form reset');
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } catch (error) {
        print("Error submitting report: $error");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Submission Failed"),
            content: const Text("An error occurred while submitting the report. Please try again."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        print('Loading state set to false');
      }
    } else {
      print('Form is invalid');
      // show an alert for invalid form
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
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: Color(0xFF0A0933),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  children: [
                    // Name Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                        hintText: 'Enter the name of the missing person',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: Validators.requiredField,
                      onSaved: (value) {
                        missingPersonName = value!;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    // Age Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        labelStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                        hintText: 'Enter estimated age',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: Validators.requiredField,
                      onSaved: (value) {
                        age = value!;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    // Gender Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        labelStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                        hintText: 'Enter gender',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: Validators.requiredField,
                      onSaved: (value) {
                        gender = value!;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    // Last Seen Date Picker
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Last Seen',
                        labelStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                        hintText: 'Choose Date',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
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
                          print('Date picked: ${_dateFormatter.format(pickedDate)}');
                        }
                      },
                      readOnly: true,
                      onSaved: (value) {
                        if (_selectedDate != null) {
                          lastSeen = _dateFormatter.format(_selectedDate!);
                        }
                      },
                    ),
                    const SizedBox(height: 16.0),
                    // Location Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'Provide where the person was last seen',
                        labelStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: Validators.requiredField,
                      onSaved: (value) {
                        location = value!;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    // Details Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Details',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Provide additional information to help find the person',
                            hintStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          style: const TextStyle(color: Colors.white),
                          maxLines: 4,
                          validator: Validators.requiredField,
                          onSaved: (value) {
                            details = value!;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 45.0),
                    // Upload Image Button using reusableButton
                    reusableButton(
                      context,
                      "Upload Image",
                      _pickImage,
                      icon: Icons.photo,
                      // customize the button appearance here
                    ),
                    // Display selected image (that's if any)
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
                    // Submit Report Button using reusableButton
                    reusableButton(
                      context,
                      "Submit Report",
                      submitReport,
                      icon: Icons.send,
                      // customize the button appearance here
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading Indicator
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
