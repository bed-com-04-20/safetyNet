class CrimeReportModel {
  final String street;
  final String city;
  final String crimeDetails;
  final String? imageUrl;
  final DateTime timestamp;
  final String status; // Add status field

  CrimeReportModel({
    required this.street,
    required this.city,
    required this.crimeDetails,
    this.imageUrl,
    required this.timestamp,
    required this.status, // Ensure status is passed in the constructor
  });

  // Convert CrimeReportModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'crimeDetails': crimeDetails,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'status': status,  // Include status in the map
    };
  }

  // Optionally, add a method to convert the map back to a model
  factory CrimeReportModel.fromMap(Map<String, dynamic> map) {
    return CrimeReportModel(
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      crimeDetails: map['crimeDetails'] ?? '',
      imageUrl: map['imageUrl'],
      timestamp: DateTime.parse(map['timestamp']),
      status: map['status'] ?? 'pending',  // Default to 'pending' if no status is provided
    );
  }
}
