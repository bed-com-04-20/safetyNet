import 'package:flutter/material.dart';
import 'dart:io';
import 'form_fields.dart';
import 'submit_button.dart';
import 'image_picker_widget.dart';
import '../../models/report_model.dart';
import '../../services/firestore_service.dart';

class ReportForm extends StatefulWidget {
  @override
  _ReportFormState createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  File? _selectedImage;
  bool _isLoading = false;

  // Form fields
  String missingPersonName = '';
  String age = '';
  String gender = '';
  String lastSeen = '';
  String location = '';
  String details = '';

  Future<void> submitReport() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        ReportModel report = ReportModel(
          missingPersonName: missingPersonName,
          age: age,
          gender: gender,
          lastSeen: lastSeen,
          location: location,
          details: details,
          imageUrl: null,
          timestamp: DateTime.now(),
          status: "submitted",
          isApproved: false,
        );

        await _firestoreService.addReport(report);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submitted successfully')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedImage = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onImagePicked(File image) {
    setState(() {
      _selectedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                NameField(onSaved: (value) => missingPersonName = value!),
                AgeField(onSaved: (value) => age = value!),
                GenderField(onSaved: (value) => gender = value!),
                LastSeenField(onSaved: (value) => lastSeen = value!),
                LocationField(onSaved: (value) => location = value!),
                DetailsField(onSaved: (value) => details = value!),
                const SizedBox(height: 16),
                ImagePickerWidget(
                  onImagePicked: _onImagePicked,
                  selectedImage: _selectedImage,
                ),
                const SizedBox(height: 16),
                SubmitButton(
                  isLoading: _isLoading,
                  onPressed: submitReport,
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
