import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/report_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/validators.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../reusable_widgets/reusable_widgets.dart';
import 'package:image/image.dart' as img;

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

  // Focus Nodes
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _ageFocusNode = FocusNode();
  final FocusNode _lastseenFocusNode = FocusNode();
  final FocusNode _genderFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();
  final FocusNode _detailsFocusNode = FocusNode();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<File> _resizeImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return file;

      final resized = img.copyResize(image, width: 800); // Resize to 800px width
      return File(file.path)..writeAsBytesSync(img.encodeJpg(resized));
    } catch (e) {
      print('Error resizing image: $e');
      return file;
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      final resizedImage = await _resizeImage(image);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('missing_persons/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final snapshot = await storageRef.putFile(resizedImage);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Error uploading image');
    }
  }

  Future<void> submitReport() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
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
          imageUrl: _imageUrl,
          timestamp: DateTime.now(),
          status: "submitted",
          isApproved: false,
        );

        await _firestoreService.addReport(newReport);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Report Submitted"),
            content:
            const Text("The missing person report has been submitted."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _formKey.currentState!.reset();
                  setState(() {
                    _selectedImage = null;
                    _dateController.text = '';
                  });
                },
                child: const Text("OK"),
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
    _nameFocusNode.dispose();
    _ageFocusNode.dispose();
    _genderFocusNode.dispose();
    _lastseenFocusNode.dispose();
    _locationFocusNode.dispose();
    _detailsFocusNode.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Color(0xFF0A0933)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  children: [
                    TextFormField(
                      focusNode: _nameFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_ageFocusNode),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        hintText: 'Enter the name of the missing person',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: Validators.requiredField,
                      onSaved: (value) => missingPersonName = value!,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      focusNode: _ageFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_genderFocusNode),
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        labelStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        hintText: 'Enter estimated age',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: Validators.requiredField,
                      onSaved: (value) => age = value!,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      focusNode: _genderFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(_lastseenFocusNode),
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        labelStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        hintText: 'Enter gender',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: Validators.requiredField,
                      onSaved: (value) => gender = value!,
                    ),
                    const SizedBox(height: 16.0),
                    // Last Seen Date Picker
                    TextFormField(
                      focusNode: _lastseenFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_locationFocusNode),
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Last Seen',
                        labelStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
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
                            _dateController.text =
                                _dateFormatter.format(pickedDate);
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
                    const SizedBox(height: 16.0),
                    TextFormField(
                      focusNode: _locationFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_detailsFocusNode),
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'Provide where the person was last seen',
                        labelStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: Validators.requiredField,
                      onSaved: (value) => location = value!,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      focusNode: _detailsFocusNode,
                      maxLines: 5,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Additional Details',
                        hintText: 'Provide any additional details',
                        labelStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSaved: (value) => details = value!,
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
                      "Submit Report",
                      submitReport,
                      icon: Icons.send,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
