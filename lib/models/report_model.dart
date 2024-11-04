class ReportModel {
  String? id;
  final String missingPersonName;
  final String age;
  final String gender;
  final String lastSeen;
  final String location;
  final String details;
  final String? imageUrl;
  final DateTime timestamp;


  ReportModel({
    this.id,
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
      'age' : age,
      'gender': gender,
      'lastSeen': lastSeen,
      'location': location,
      'details': details,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      //id: map['id'], // This line assumes you stored the id in the map
      missingPersonName: map['missingPersonName'],
      age: map['age'],
      gender: map['gender'],
      lastSeen: map['lastSeen'],
      location: map['location'],
      details: map['details'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
