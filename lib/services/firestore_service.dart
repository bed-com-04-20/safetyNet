import 'package:firebase_database/firebase_database.dart';
import '../models/report_model.dart';
import '../models/crime_report_model.dart'; // Import the CrimeReportModel

class RealtimeDatabaseService {
  // Reference to the root of the Firebase Realtime Database
  final DatabaseReference reportsRef =
  FirebaseDatabase.instance.ref().child('missing_person_reports');

  final DatabaseReference crimeReportsRef =
  FirebaseDatabase.instance.ref().child('crime_reports');

  // Add a missing person report to the Realtime Database
  Future<void> addReport(ReportModel report) async {
    try {
      await reportsRef.push().set(report.toMap()); // Use toMap() instead of toJson()
    } catch (error) {
      throw Exception("Error adding report: $error");
    }
  }

  // Fetch missing person reports from the Realtime Database
  Future<List<ReportModel>> fetchReports() async {
    try {
      final DataSnapshot snapshot = await reportsRef.get(); // Use get() instead of once()
      if (snapshot.exists) { // Check if the snapshot has data
        Map<dynamic, dynamic> reportsMap = snapshot.value as Map<dynamic, dynamic>;

        // Convert the map to a list of ReportModel
        return reportsMap.entries.map((entry) {
          final data = entry.value;
          return ReportModel(
            missingPersonName: data['missingPersonName'],
            age: data['age'],
            gender: data['gender'],
            lastSeen: data['lastSeen'],
            location: data['location'],
            details: data['details'],
            timestamp: data['timestamp'] as int, // Use fromMillisecondsSinceEpoch
          );
        }).toList();
      } else {
        return []; // Return an empty list if no data exists
      }
    } catch (error) {
      throw Exception("Error fetching reports: $error");
    }
  }

  // Add a crime report to the Realtime Database
  Future<void> addCrimeReport(CrimeReportModel crimeReport) async {
    try {
      await crimeReportsRef.push().set(crimeReport.toMap()); // Use toMap() instead of toJson()
    } catch (error) {
      throw Exception("Error adding crime report: $error");
    }
  }

  // Fetch crime reports from the Realtime Database
  Future<List<CrimeReportModel>> fetchCrimeReports() async {
    try {
      final DataSnapshot snapshot = await crimeReportsRef.get(); // Use get() instead of once()
      if (snapshot.exists) { // Check if the snapshot has data
        Map<dynamic, dynamic> crimeReportsMap = snapshot.value as Map<dynamic, dynamic>;

        // Convert the map to a list of CrimeReportModel
        return crimeReportsMap.entries.map((entry) {
          final data = entry.value;
          return CrimeReportModel(
            street: data['street'],
            city: data['city'],
            crimeDetails: data['crimeDetails'],
            imageUrl: data['imageUrl'],
            timestamp: data['timestamp'], // Directly use as int
          );
        }).toList();
      } else {
        return []; // Return an empty list if no data exists
      }
    } catch (error) {
      throw Exception("Error fetching crime reports: $error");
    }
  }
}
