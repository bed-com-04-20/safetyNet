class ReportModel {
  final String missingPersonName;
  final String age;
  final String gender;
  final String lastSeen;
  final String location;
  final String details;
  final String? imageUrl;
  final DateTime timestamp;
  final String status;
  final bool isApproved;

  ReportModel({
    required this.missingPersonName,
    required this.age,
    required this.gender,
    required this.lastSeen,
    required this.location,
    required this.details,
    this.imageUrl,
    required this.timestamp,
    this.status = 'submitted',
    this.isApproved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'missingPersonName': missingPersonName,
      'age': age,
      'gender': gender,
      'lastSeen': lastSeen,
      'location': location,
      'details': details,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'isApproved': isApproved,
    };
  }
}
