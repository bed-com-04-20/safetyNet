import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class AdminReportScreen extends StatefulWidget {
  @override
  _AdminReportScreenState createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedStatusFilter = "All"; // Filter for report status
  final List<String> _statusOptions = ["All", "submitted", "seen", "approved"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Reports"),
        actions: [
          // Notification badge for new reports
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('missing_person_reports')
                .where('status', isEqualTo: 'submitted')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              int newReportsCount = snapshot.data!.docs.length;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.notifications),
                    if (newReportsCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '$newReportsCount',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter dropdown for status
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedStatusFilter,
              onChanged: (newValue) {
                setState(() {
                  _selectedStatusFilter = newValue!;
                });
              },
              items: _statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('missing_person_reports')
                  .where(
                'status',
                isEqualTo: _selectedStatusFilter != "All" ? _selectedStatusFilter : null,
              )
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final reports = snapshot.data!.docs;
                if (reports.isEmpty) {
                  return Center(child: Text("No reports found"));
                }

                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    var report = reports[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      child: ListTile(
                        title: Text(report['missingPersonName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${report['status']}'),
                            Text('Details: ${report['details']}'),
                          ],
                        ),
                        trailing: Column(
                          children: [
                            // Toggle visibility
                            Switch(
                              value: report['visibleToUsers'] ?? false,
                              onChanged: (value) {
                                _firestoreService.updateReportVisibility(
                                  report.id,
                                  value,
                                );
                              },
                            ),
                            Text("Visible to users"),
                          ],
                        ),
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Update Report"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Dropdown for status update
                                  DropdownButton<String>(
                                    value: report['status'],
                                    items: ["submitted", "seen", "approved"]
                                        .map((status) => DropdownMenuItem(
                                      child: Text(status),
                                      value: status,
                                    ))
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        _firestoreService.updateReportStatus(
                                          report.id,
                                          value,
                                          report['visibleToUsers'] ?? false,
                                        );
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  // Button to delete report
                                  TextButton(
                                    onPressed: () async {
                                      bool confirm = await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text("Delete Report"),
                                          content: Text("Are you sure you want to delete this report?"),
                                          actions: [
                                            TextButton(
                                              child: Text("Cancel"),
                                              onPressed: () => Navigator.pop(context, false),
                                            ),
                                            TextButton(
                                              child: Text("Delete"),
                                              onPressed: () => Navigator.pop(context, true),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm) {
                                        await _firestoreService.deleteReport(report.id);
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Text("Delete Report"),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
