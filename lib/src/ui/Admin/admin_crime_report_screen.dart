import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safetynet/src/ui/signIn.dart';
import '../../../../../../services/firestore_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'admins_approval.dart';
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

  // Listen for unread notifications from Firebase
  void _listenForUnreadNotifications() {
    FirebaseDatabase.instance.ref('notifications/user1').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        int unreadCount = data.values.where((notification) => notification['read'] == false).length;
        setState(() {
          _unreadNotificationCount = unreadCount;
        });
      }
    });
  }

  // Update crime report status in Firestore
  Future<void> _updateReportStatus(String reportId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('crime_reports').doc(reportId).update({
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

  // Toggle visibility of the crime report
  Future<void> _updateReportVisibility(String reportId, bool visible) async {
    try {
      await FirebaseFirestore.instance.collection('crime_reports').doc(reportId).update({
        'visibleToUsers': visible,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(visible
            ? 'Crime report is now visible to users'
            : 'Crime report is now hidden from users')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update visibility: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _listenForUnreadNotifications();
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
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
      body: Stack(
        children: [
          Column(
            children: [
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
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: (_selectedStatusFilter == "All"
                      ? FirebaseFirestore.instance.collection('crime_reports')
                      : FirebaseFirestore.instance
                      .collection('crime_reports')
                      .where('status', isEqualTo: _selectedStatusFilter))
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
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
                            trailing: Switch(
                              value: reportData['visibleToUsers'] ?? false,
                              onChanged: (value) {
                                _updateReportVisibility(report.id, value);
                              },
                            ),
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
                                _updateReportStatus(report.id, selectedStatus);
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
          // Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF0A0933),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              margin: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BottomNavigationBar(
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white60,
                  backgroundColor: Colors.transparent,
                  onTap: (index) {
                    setState(() {
                      // Update the current index for navigation
                    });

                    // Navigate based on the selected index
                    if (index == 0) {
                      // Navigate to the Reports page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminReportScreen(),
                        ),
                      );
                    } else if (index == 1) {
                      // Navigate to the Add Report page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminCrimeReportScreen(),
                        ),
                      );
                    }
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Report missing person',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
