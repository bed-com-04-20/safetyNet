import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CrimeReportListScreen extends StatefulWidget {
  @override
  _CrimeReportListScreenState createState() => _CrimeReportListScreenState();
}

class _CrimeReportListScreenState extends State<CrimeReportListScreen> {
  final CollectionReference crimeReportsCollection =
  FirebaseFirestore.instance.collection('crime_reports');
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to approve the report (by admin)
  Future<void> _approveReport(String reportId) async {
    try {
      await crimeReportsCollection.doc(reportId).update({
        'status': 'approved',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report approved successfully!")),
      );
    } catch (e) {
      print("Error approving report: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error approving the report")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0933),
      appBar: AppBar(
        title: const Text(
          'Crime Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0A0933),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search by street or city',
                labelStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.blueAccent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: crimeReportsCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Error fetching crime reports',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData) {
                  final reports = snapshot.data!.docs
                      .where((doc) {
                    String street = doc['street'] ?? '';
                    String city = doc['city'] ?? '';
                    return street.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        city.toLowerCase().contains(_searchQuery.toLowerCase());
                  })
                      .toList();

                  if (reports.isEmpty) {
                    return const Center(
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
                      String street = doc['street'] ?? 'Unknown';
                      String city = doc['city'] ?? 'Unknown';
                      String crimeDetails = doc['crimeDetails'] ?? 'No details provided';
                      String imageUrl = doc['imageUrl'] ?? '';
                      String status = doc['status'] ?? 'submitted';
                      String reportId = doc.id;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
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
                                          const Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error, color: Colors.red, size: 100),
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
                                    child: const Icon(
                                      Icons.report,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Street: $street',
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'City: $city',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white60,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Details: $crimeDetails',
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.white60,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        'Status: $status',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: status == 'approved'
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      if (status == 'submitted')
                                        SizedBox(height: 8.0),
                                      if (status == 'submitted')
                                        ElevatedButton(
                                          onPressed: () => _approveReport(reportId),
                                          child: Text('Approve Report'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return Center(
                  child: Text(
                    'No crime reports found',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
