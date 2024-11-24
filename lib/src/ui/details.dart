import 'package:flutter/material.dart';
import '../../reusable_widgets/reusable_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'replies.dart';

class DetailScreen extends StatelessWidget {
  final String name;
  final String lastSeen;
  final String location;
  final String details;
  final String imageUrl;
  final String reportId;

  const DetailScreen({
    required this.name,
    required this.lastSeen,
    required this.location,
    required this.details,
    required this.imageUrl,
    required this.reportId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details of $name')),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Color(0xFF0A0933),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32.0),
                    bottomRight: Radius.circular(32.0),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 400,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32.0),
                    bottomRight: Radius.circular(32.0),
                  ),
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 120,
                      color: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'Name: $name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'Last Seen: $lastSeen',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'Location: $location',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'Details: $details',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: reusableButton(
                  context,
                  'Reply',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationScreen(
                          name: name,
                          reportId: reportId,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
