import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                        // Navigate to a detailed view or perform another action
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                        ),
                        child: Card(
                          color: Colors.transparent,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image Section
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
                                          Icon(Icons.error,
                                              color: Colors.red, size: 100),
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

                                // Information Section
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        'Last Seen: $lastSeen',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        'Location: $location',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        'Details: $details',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black87,
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

class DetailScreen extends StatelessWidget {
  final String name;
  final String lastSeen;
  final String location;
  final String details;
  final String imageUrl;

  DetailScreen({
    required this.name,
    required this.lastSeen,
    required this.location,
    required this.details,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details of $name')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            SizedBox(height: 16.0),
            Text(
              'Name: $name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 8.0),
            Text('Last Seen: $lastSeen'),
            SizedBox(height: 8.0),
            Text('Location: $location'),
            SizedBox(height: 8.0),
            Text('Details: $details'),
          ],
        ),
      ),
    );
  }
}
