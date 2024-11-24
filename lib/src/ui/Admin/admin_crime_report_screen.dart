import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safetynet/src/ui/signIn.dart';
import '../../../../../../services/firestore_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'admins_replay.dart';

class AdminCrimeReportScreen extends StatefulWidget {
  const AdminCrimeReportScreen({super.key});

  @override
  _AdminCrimeReportScreenState createState() => _AdminCrimeReportScreenState();
}

class _AdminCrimeReportScreenState extends State<AdminCrimeReportScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedStatusFilter = "All";
  final List<String> _statusOptions = ["All", "submitted", "approved", "rejected"];
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _listenForUnreadNotifications();
  }

  // Listen for unread notifications
  void _listenForUnreadNotifications() {
    FirebaseDatabase.instance.ref('notifications/user1').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        int unreadCount = data.values
            .where((notification) => notification['read'] == false)
            .length;
        setState(() {
          _unreadNotificationCount = unreadCount;
        });
      }
    });
  }

  // Common method to update Firestore fields
  Future<void> _updateFirestoreField(
      String collection, String docId, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection(collection).doc(docId).update(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  // Delete a report from Firestore
  Future<void> _deleteReport(String reportId) async {
    try {
      await FirebaseFirestore.instance.collection('crime_reports').doc(reportId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.notification_add, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ConversationListScreen()),
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Crime Reports',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.logout_outlined, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInPage()),
                    );
                  },
                ),
                if (_unreadNotificationCount > 0)
                  Positioned(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '$_unreadNotificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0A0933),
      ),
      backgroundColor: const Color(0xFF0A0933),
      body: Column(
        children: [
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(status),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          // Crime Reports List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (_selectedStatusFilter == "All"
                  ? FirebaseFirestore.instance.collection('crime_reports')
                  : FirebaseFirestore.instance
                  .collection('crime_reports')
                  .where('status', isEqualTo: _selectedStatusFilter))
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reports = snapshot.data!.docs;

                if (reports.isEmpty) {
                  return const Center(child: Text("No reports found"));
                }

                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    var report = reports[index];
                    var reportData = report.data() as Map<String, dynamic>;

                    return Card(
                      color: Colors.blueAccent.withOpacity(0.3),
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                      child: ListTile(
                        title: Text(
                          reportData['crimeDetails'] ?? 'Unknown Crime',
                          style: const TextStyle(
                            color: Color(0xFFEB6958),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Status: ${reportData['status'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Visibility Toggle
                            Switch(
                              value: reportData['visibleToUsers'] ?? false,
                              onChanged: (value) {
                                _updateFirestoreField('crime_reports', report.id,
                                    {'visibleToUsers': value});
                              },
                            ),
                            // Delete Button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                bool? confirmDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: const Text(
                                          'Are you sure you want to delete this report?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmDelete == true) {
                                  _deleteReport(report.id);
                                }
                              },
                            ),
                          ],
                        ),
                        // Status Update on Tap
                        onTap: () async {
                          String? selectedStatus = await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Select Status'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: _statusOptions.map((status) {
                                    return ListTile(
                                      title: Text(status),
                                      onTap: () {
                                        Navigator.pop(context, status);
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          );
                          if (selectedStatus != null) {
                            _updateFirestoreField('crime_reports', report.id,
                                {'status': selectedStatus});
                          }
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
