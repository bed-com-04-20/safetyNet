import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../reusable_widgets/reusable_widgets.dart';
import 'details.dart';

class ReportListScreen extends StatefulWidget {
  @override
  _ReportListScreenState createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final CollectionReference reportsCollection =
  FirebaseFirestore.instance.collection('missing_person_reports');
  String _searchQuery = "";
  String _selectedStatusFilter = "approved";
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0933),
      appBar: AppBar(
        title: Text(
          'Missing Person Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,

          ),
        ),
        backgroundColor: Color(0xFF0A0933),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: reusableTextField(
              'Search missing person by name',
              Icons.search,
              false,
              _searchController,
              iconColor: Colors.white70,
              fillColor: Colors.blueAccent,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Color(0xFF0A0933),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: reportsCollection
                    .where('status', isEqualTo: _selectedStatusFilter)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error fetching reports', style: TextStyle(color: Colors.white)));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData) {
                    final reports = snapshot.data!.docs
                        .where((doc) {
                      String name = doc['missingPersonName'] ?? '';
                      return name.toLowerCase().contains(_searchQuery.toLowerCase());
                    })
                        .toList();

                    if (reports.isEmpty) {
                      return Center(
                        child: Text(
                          'No matching reports found',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        var doc = reports[index];
                        String reportId = doc.id; // Unique identifier for the report
                        String name = doc['missingPersonName'] ?? 'Unknown';
                        String lastSeen = doc['lastSeen'] ?? 'Unknown';
                        String location = doc['location'] ?? 'Unknown';
                        String details = doc['details'] ?? 'No details provided';
                        String imageUrl = doc['imageUrl'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                    name: name,
                                    lastSeen: lastSeen,
                                    location: location,
                                    details: details,
                                    imageUrl: imageUrl,
                                    reportId: reportId, // Pass the unique identifier
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.blueAccent.withOpacity(0.3),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (imageUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Center(child: CircularProgressIndicator()),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error, color: Colors.red, size: 100),
                                        ),
                                      )
                                    else
                                      Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                      ),
                                    SizedBox(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            'Last Seen: $lastSeen',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.white60,
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            'Location: $location',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.white60,
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            'Details: $details',
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.white60,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return Center(
                    child: Text(
                      'No reports found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
