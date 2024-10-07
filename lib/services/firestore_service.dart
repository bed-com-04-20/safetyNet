import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class FirestoreService {
  final CollectionReference reportsCollection =
  FirebaseFirestore.instance.collection('missing_person_reports');

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
}
