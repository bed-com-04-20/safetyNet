import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ReportListScreen extends StatefulWidget {
  @override
  _ReportListScreenState createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<ReportModel>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _firestoreService.fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D7BD9FF),
      appBar: AppBar(
        title: Text('Missing Person Reports'),
      ),
      body: FutureBuilder<List<ReportModel>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No reports found.'));
          }

          final reports = snapshot.data!;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              print('Image URL: ${report.imageUrl}');

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Picture section
                        if (report.imageUrl != null && report.imageUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: report.imageUrl!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red, size: 100),
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

                        // Information section
                        Expanded(
                          child: Column(

                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // Name
                              Text(
                                report.missingPersonName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                              SizedBox(height: 8.0),

                              // Last Seen
                              Text(
                                'Last Seen: ${report.lastSeen}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 8.0),

                              // Location
                              Text(
                                'Location: ${report.location}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 8.0),

                              // Details
                              Text(
                                'Details: ${report.details}',
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
              );
            },
          );
        },
      ),
    );
  }
}
