import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../utils/colors_utils.dart';

class ReportListScreen extends StatelessWidget {
  final DatabaseReference reportsRef =
  FirebaseDatabase.instance.ref().child('missing_person_reports');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Missing Person Reports'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: hexStringToColor("615EFC"),
        ),
        child: StreamBuilder<DatabaseEvent>(
          stream: reportsRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error fetching reports'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            // Check if we have data
            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              // Retrieve the data from the snapshot
              Map<dynamic, dynamic> reportsMap =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

              // Convert the map to a list of reports
              List<dynamic> reportsList = reportsMap.values.toList();

              return ListView.builder(
                itemCount: reportsList.length,
                itemBuilder: (context, index) {
                  var report = reportsList[index];
                  String name = report['missingPersonName'] ?? 'Unknown';
                  String lastSeen = report['lastSeen'] ?? 'Unknown';
                  String location = report['location'] ?? 'Unknown';
                  String details = report['details'] ?? 'No details provided';
                  String imageUrl = report['imageUrl'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
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
                                        Icon(Icons.error, color: Colors.red, size: 100),
                                  ),
                                )
                              else
                              // Placeholder if no image
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Name
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),

                                    // Last Seen
                                    Text(
                                      'Last Seen: $lastSeen',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),

                                    // Location
                                    Text(
                                      'Location: $location',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),

                                    // Details
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
