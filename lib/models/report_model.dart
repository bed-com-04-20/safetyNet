class ReportModel {
  final String missingPersonName;
  final String age;
  final String gender;
  final String lastSeen;
  final String location;
  final String details;
  final String? imageUrl; // Make imageUrl nullable if not always provided
  final int timestamp;

  ReportModel({
    required this.missingPersonName,
    required this.age,
    required this.gender,
    required this.lastSeen,
    required this.location,
    required this.details,
    this.imageUrl,
    required this.timestamp,
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
      'timestamp': timestamp,
    };
  }

  // Optional: If you need a method to convert to JSON, you can keep this
  Map<String, dynamic> toJson() => toMap(); // Use the same method
}
