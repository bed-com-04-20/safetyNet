import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'details.dart';

class ReportListScreen extends StatelessWidget {
  final CollectionReference reportsCollection =
  FirebaseFirestore.instance.collection('missing_person_reports');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE18888),
      appBar: AppBar(
        title: Text('Missing Person Reports'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Color(0xFF0A0933),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: reportsCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error fetching reports'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData) {
              final reports = snapshot.data!.docs;

              return ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  var doc = reports[index];
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
                                        CircularProgressIndicator(),
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

            return Center(child: Text('No reports found'));
          },
        ),
      ),
    );
  }
}
