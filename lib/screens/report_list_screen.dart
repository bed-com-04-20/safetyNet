import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';

class ReportListScreen extends StatefulWidget {
  @override
  _ReportListScreenState createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<ReportModel>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _firestoreService.fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: Text('Missing Person Reports'),
      ),
      body: FutureBuilder<List<ReportModel>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No reports found.'));
          }

          final reports = snapshot.data!;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return ListTile(
                title: Text(report.missingPersonName),
                subtitle: Text('Last Seen: ${report.lastSeen}'),
                onTap: () {
                  // You can navigate to a detailed report view here if needed
                },
              );
            },
          );
        },
      ),
    );
  }
}
