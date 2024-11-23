import 'package:flutter/material.dart';
import '../../utils/validators.dart';

class NameField extends StatelessWidget {
  final Function(String?) onSaved;

  const NameField({required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Name'),
      validator: Validators.requiredField,
      onSaved: onSaved,
    );
  }
}

class AgeField extends StatelessWidget {
  final Function(String?) onSaved;

  const AgeField({required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Age'),
      validator: Validators.requiredField,
      onSaved: onSaved,
    );
  }
}

class GenderField extends StatelessWidget {
  final Function(String?) onSaved;

  const GenderField({required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Gender'),
      validator: Validators.requiredField,
      onSaved: onSaved,
    );
  }
}

class LastSeenField extends StatelessWidget {
  final Function(String?) onSaved;

  const LastSeenField({required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Last Seen'),
      validator: Validators.requiredField,
      onSaved: onSaved,
    );
  }
}

class LocationField extends StatelessWidget {
  final Function(String?) onSaved;

  const LocationField({required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Location'),
      validator: Validators.requiredField,
      onSaved: onSaved,
    );
  }
}

class DetailsField extends StatelessWidget {
  final Function(String?) onSaved;

  const DetailsField({required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Details'),
      maxLines: 4,
      validator: Validators.requiredField,
      onSaved: onSaved,
    );
  }
}
