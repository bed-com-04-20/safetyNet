class CrimeReportModel {
  final String street;
  final String city;
  final String crimeDetails;
  final String? imageUrl;
  final DateTime timestamp;

  CrimeReportModel({
    required this.street,
    required this.city,
    required this.crimeDetails,
    this.imageUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'crimeDetails': crimeDetails,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
