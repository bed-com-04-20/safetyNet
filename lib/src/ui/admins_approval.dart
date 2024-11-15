import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safetynet/src/ui/signIn.dart';
import '../../services/firestore_service.dart';

class AdminReportScreen extends StatefulWidget {
  @override
  _AdminReportScreenState createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedStatusFilter = "All";
  final List<String> _statusOptions = ["All", "submitted", "seen", "approved"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Missing Person Reports',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('missing_person_reports')
                  .where('status', isEqualTo: 'submitted')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  int count = snapshot.data!.docs.length;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.notifications, color: Colors.white),
                      if (count > 0)
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                } else {
                  return Icon(Icons.notifications, color: Colors.white);
                }
              },
            ),
          ],
        ),
        backgroundColor: Color(0xFF0A0933),
      ),
      backgroundColor: Color(0xFF0A0933),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatusFilter,
                    dropdownColor: Colors.white,
                    iconEnabledColor: Colors.black,
                    style: TextStyle(color: Colors.white),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedStatusFilter = newValue!;
                      });
                    },
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(
                          status,
                          style: TextStyle(
                            color: status == "All" ? Colors.black : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
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
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      var report = reports[index];
                      var reportData = report.data() as Map<String, dynamic>;
                      return Card(
                        color: Colors.blueAccent.withOpacity(0.3),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                        child: ListTile(
                          title:Text(
                            reportData['missingPersonName'] ?? 'Unknown',
                            style: TextStyle(
                              color: Color(0xFFEB6958),
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Status: ${reportData['status'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.white70,
                                  ),
                              ),
                              Text(
                                  'Details: ${reportData['details'] ?? 'No details available'}',
                                  style: TextStyle(
                                    color: Colors.white70,
                                  ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            children: [
                              Switch(
                                value: reportData['visibleToUsers'] ?? false,
                                onChanged: (value) {
                                  _firestoreService.updateReportVisibility(
                                    report.id,
                                    value,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        value ? 'Report is now visible to users' : 'Report is now hidden from users',
                                      ),
                                    ),
                                  );
                                },
                                activeColor: Color(0xFFEB6958),
                                inactiveThumbColor: Colors.grey,
                                inactiveTrackColor: Colors.grey[300],
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
                                    DropdownButton<String>(
                                      value: reportData['status'] ?? 'submitted',
                                      items: ["submitted", "seen", "approved"]
                                          .map((status) => DropdownMenuItem(
                                        child: Text(status),
                                        value: status,
                                      ))
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          bool isVisible = value == "approved";
                                          _firestoreService.updateReportStatus(
                                            report.id,
                                            value,
                                            isVisible,
                                          ).then((_) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Report status updated to $value'),
                                              ),
                                            );
                                            Navigator.pop(context);
                                          });
                                        }
                                      },
                                    ),
                                    SizedBox(height: 10),
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
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Report deleted successfully'),
                                            ),
                                          );
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
            ],
          ),
        ),
      ),
    );
  }
}
