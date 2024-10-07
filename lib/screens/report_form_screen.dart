import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';
import '../utils/validators.dart';
import 'package:intl/intl.dart';

import 'report_list_screen.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  DateTime? _selectedDate;

  // Form fields
  String missingPersonName = '';
  String age = '';
  String gender = '';
  String lastSeen = '';
  String location = '';
  String details = '';

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  // Submit the form to Firestore
  Future<void> submitReport() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ReportModel newReport = ReportModel(
        missingPersonName: missingPersonName,
        age: age,
        gender: gender,
        lastSeen: lastSeen,
        location: location,
        details: details,
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

        //to nagitave to report list
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => ReportListScreen()),
        // );

      } catch (error) {
        print("Error submitting report: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                decoration: InputDecoration(labelText: 'Name'),
                validator: Validators.requiredField,
                onSaved: (value) {
                  missingPersonName = value!;
                },
              ),
              SizedBox(height: 16.0),

              // Input for missing person age
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                validator: Validators.requiredField,
                onSaved: (value) {
                  age = value!;
                },
              ),
              SizedBox(height: 16.0),

              // Input for missing person gender
              TextFormField(
                decoration: InputDecoration(labelText: 'Gender'),
                validator: Validators.requiredField,
                onSaved: (value) {
                  gender = value!;
                },
              ),
              SizedBox(height: 16.0),

              // Input for missing person last seen
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Last Seen',
                  hintText: _selectedDate == null
                      ? 'Choose Date'
                      : _dateFormatter.format(_selectedDate!), // Display selected date
                ),
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'Please choose a date';
                  }
                  return null;
                },
                onTap: () async {
                  // Open date picker when field is tapped
                  FocusScope.of(context).requestFocus(FocusNode()); // Prevents keyboard from showing
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
                readOnly: true, // Prevent manual input
                onSaved: (value) {
                  if (_selectedDate != null) {
                    lastSeen = _dateFormatter.format(_selectedDate!);
                  }
                },
              ),
              SizedBox(height: 16.0),

              // Input for location
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                validator: Validators.requiredField,
                onSaved: (value) {
                  location = value!;
                },
              ),
              SizedBox(height: 16.0),

              // Input for details
              TextFormField(
                decoration: InputDecoration(labelText: 'Details'),
                validator: Validators.requiredField,
                onSaved: (value) {
                  details = value!;
                },
              ),
              SizedBox(height: 45.0),

              // Submit button
              ElevatedButton(
                onPressed: submitReport,
                child: Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
