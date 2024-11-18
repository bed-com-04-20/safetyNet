import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safetynet/src/ui/signIn.dart';
import '../../../../../../services/firestore_service.dart';
import 'admins_replay.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  _AdminReportScreenState createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedStatusFilter = "All";
  final List<String> _statusOptions = ["All", "submitted", "seen", "approved"];
  String _newStatus = "submitted";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignInPage()),
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Missing Person Reports',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConversationListScreen()),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.notifications, color: Colors.white),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('missing_person_reports')
                        .where('status', isEqualTo: 'submitted')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        int count = snapshot.data!.docs.length;
                        return count > 0
                            ? Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                            : Container();
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0A0933),
      ),
      backgroundColor: const Color(0xFF0A0933),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Status Filter Dropdown
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatusFilter,
                    dropdownColor: Colors.white,
                    iconEnabledColor: Colors.black,
                    style: const TextStyle(color: Colors.black),
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
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Report List
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('missing_person_reports')
                    .where(
                  'status',
                  isEqualTo: _selectedStatusFilter != "All" ? _selectedStatusFilter : null,
                )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final reports = snapshot.data!.docs;
                  if (reports.isEmpty) {
                    return const Center(child: Text("No reports found"));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                        child: ListTile(
                          title: Text(
                            reportData['missingPersonName'] ?? 'Unknown',
                            style: const TextStyle(
                              color: Color(0xFFEB6958),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status: ${reportData['status'] ?? 'N/A'}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                'Details: ${reportData['details'] ?? 'No details available'}',
                                style: const TextStyle(color: Colors.white70),
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
                                activeColor: const Color(0xFFEB6958),
                                inactiveThumbColor: Colors.grey,
                                inactiveTrackColor: Colors.grey[300],
                              ),
                              const Text("Visible to users"),
                              // Status update dropdown for admin
                              DropdownButton<String>(
                                value: _newStatus,
                                onChanged: (newStatus) {
                                  setState(() {
                                    _newStatus = newStatus!;
                                  });
                                  _updateReportStatus(report.id, _newStatus);
                                },
                                items: _statusOptions.map((status) {
                                  return DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          onTap: () async {
                            // Future implementation for tapping on a report if needed
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

  // Update report status in Firestore
  Future<void> _updateReportStatus(String reportId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('missing_person_reports')
          .doc(reportId)
          .update({
        'status': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }
}
