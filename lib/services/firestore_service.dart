import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';
import '../models/crime_report_model.dart'; // Import the CrimeReportModel

class FirestoreService {
  // Collection for missing person reports
  final CollectionReference reportsCollection =
  FirebaseFirestore.instance.collection('missing_person_reports');

  // Collection for crime reports
  final CollectionReference crimeReportsCollection =
  FirebaseFirestore.instance.collection('crime_reports');

  // Add a missing person report to Firestore
  Future<void> addReport(ReportModel report) async {
    try {
      await reportsCollection.add(report.toMap());
    } catch (error) {
      throw Exception("Error adding report: $error");
    }
  }

  // Fetch missing person reports from Firestore
  Future<List<ReportModel>> fetchReports() async {
    try {
      QuerySnapshot snapshot = await reportsCollection.get();
      return snapshot.docs.map((doc) {
        return ReportModel(
          missingPersonName: doc['missingPersonName'],
          age: doc['age'],
          gender: doc['gender'],
          lastSeen: doc['lastSeen'],
          location: doc['location'],
          details: doc['details'],
          timestamp: DateTime.parse(doc['timestamp']),
        );
      }).toList();
    } catch (error) {
      throw Exception("Error fetching reports: $error");
    }
  }

  // Add a crime report to Firestore
  Future<void> addCrimeReport(CrimeReportModel crimeReport) async {
    try {
      await crimeReportsCollection.add(crimeReport.toMap());
    } catch (error) {
      throw Exception("Error adding crime report: $error");
    }
  }

  // Fetch crime reports from Firestore
  Future<List<CrimeReportModel>> fetchCrimeReports() async {
    try {
      QuerySnapshot snapshot = await crimeReportsCollection.get();
      return snapshot.docs.map((doc) {
        return CrimeReportModel(
          street: doc['street'],
          city: doc['city'],
          crimeDetails: doc['crimeDetails'],
          imageUrl: doc['imageUrl'],
          timestamp: DateTime.parse(doc['timestamp']),
        );
      }).toList();
    } catch (error) {
      throw Exception("Error fetching crime reports: $error");
    }
  }
}
