import 'package:flutter/material.dart';

void main() {
  runApp(MissingPersonsApp());
}

class MissingPersonsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Missing Persons',
      home: MissingPersonsScreen(),
    );
  }
}

class MissingPersonsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search  Missing Persons'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button action
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '10 missing persons found',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 20),
            PersonCard(
              name: 'Vero Raff',
              lastSeen: 'Chikanda rural',
              details: 'The person ...',
              imageUrl: 'https://via.placeholder.com/150', // Placeholder image
            ),
            // Add more PersonCard widgets as needed
          ],
        ),
      ),
    );
  }
}

class PersonCard extends StatelessWidget {
  final String name;
  final String lastSeen;
  final String details;
  final String imageUrl;

  PersonCard({
    required this.name,
    required this.lastSeen,
    required this.details,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: $name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Last seen: $lastSeen'),
            Text('Details: $details'),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                imageUrl,
                height: 150.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
