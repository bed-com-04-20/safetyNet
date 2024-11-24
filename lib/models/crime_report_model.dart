import 'package:cloud_firestore/cloud_firestore.dart';

class CrimeReportModel {
  final String crimeTitle;
  final String street;
  final String city;
  final String crimeDetails;
  final String? imageUrl;
  final DateTime timestamp;
  final String status;

  CrimeReportModel({
    required this.crimeTitle,
    required this.street,
    required this.city,
    required this.crimeDetails,
    this.imageUrl,
    required this.timestamp,
    required this.status,
  });

  // Adding CrimeTitle to the fromFirestore factory
  factory CrimeReportModel.fromFirestore(DocumentSnapshot doc) {
    return CrimeReportModel(
      crimeTitle: doc['CrimeTitle'] ?? 'Unknown Crime Title', // Default value if not found
      street: doc['street'] ?? '',
      city: doc['city'] ?? '',
      crimeDetails: doc['crimeDetails'] ?? '',
      imageUrl: doc['imageUrl'],
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
      status: doc['status'] ?? 'pending',
    );
  }

  // To convert the model to a map for Firestore submission
  Map<String, dynamic> toMap() {
    return {
      'CrimeTitle': crimeTitle,
      'street': street,
      'city': city,
      'crimeDetails': crimeDetails,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'status': status,
    };
  }
}
