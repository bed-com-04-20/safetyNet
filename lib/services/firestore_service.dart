import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';
import '../models/crime_report_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection for missing person reports
  final CollectionReference reportsCollection = FirebaseFirestore.instance.collection('missing_person_reports');

  // Collection for crime reports
  final CollectionReference crimeReportsCollection = FirebaseFirestore.instance.collection('crime_reports');

  // Add a missing person report to Firestore
  Future<void> addReport(ReportModel report) async {
    try {
      await reportsCollection.add(report.toMap());
    } catch (error) {
      throw Exception("Error adding report: $error");
    }
  }

  // Fetch missing person reports from Firestore
  Future<List<ReportModel>> fetchReports(String status) async {
    try {
      QuerySnapshot snapshot;

      // If status is 'All', fetch all reports
      if (status == 'All') {
        snapshot = await reportsCollection.get();
      } else {
        snapshot = await reportsCollection.where('status', isEqualTo: status).get();
      }

      return snapshot.docs.map((doc) {
        return ReportModel(
          missingPersonName: doc['missingPersonName'],
          age: doc['age'],
          gender: doc['gender'],
          lastSeen: doc['lastSeen'],
          location: doc['location'],
          details: doc['details'],
          imageUrl: doc['imageUrl'],
          timestamp: DateTime.parse(doc['timestamp']),
        );
      }).toList();
    } catch (error) {
      throw Exception("Error fetching reports: $error");
    }
  }

  // Update report status and visibility for missing person reports
  Future<void> updateReportStatus(String reportId, String status, bool visibleToUsers) async {
    try {
      await reportsCollection.doc(reportId).update({
        'status': status,
        'visibleToUsers': visibleToUsers,
      });
    } catch (error) {
      throw Exception("Error updating report status: $error");
    }
  }

  // Update report visibility only
  Future<void> updateReportVisibility(String reportId, bool visibleToUsers) async {
    try {
      await reportsCollection.doc(reportId).update({'visibleToUsers': visibleToUsers});
    } catch (error) {
      throw Exception("Error updating report visibility: $error");
    }
  }

  // Delete a report
  Future<void> deleteReport(String reportId) async {
    try {
      await reportsCollection.doc(reportId).delete();
    } catch (error) {
      throw Exception("Error deleting report: $error");
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

  // Reply to a missing person report (admin replies)
  Future<void> replyToMessage(String reportId, String senderId, String replyText) async {
    var reportRef = reportsCollection.doc(reportId);

    try {
      await reportRef.update({
        'messages': FieldValue.arrayUnion([
          {
            'text': replyText,
            'senderId': senderId, // Use the Admin's ID or hardcode 'Admin'
            'timestamp': FieldValue.serverTimestamp(),
            'isReplied': true, // Mark as replied
          },
        ]),
      });
    } catch (error) {
      throw Exception("Error replying to message: $error");
    }
  }
}
