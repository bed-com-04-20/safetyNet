import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../replies.dart';

class ConversationListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Conversations',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A0933),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF0A0933),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref('messages').onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.snapshot.value;
          final Map<dynamic, dynamic> castedData = data is Map ? data : {};

          if (castedData.isEmpty) {
            return const Center(child: Text("No data found", style: TextStyle(color: Colors.white)));
          }

          final reports = castedData.entries.where((entry) {
            final messages = entry.value as Map<dynamic, dynamic>? ?? {};
            return messages.values.any((msg) {
              if (msg is Map<dynamic, dynamic>) {
                return msg['text']?.toString().isNotEmpty ?? false;
              }
              return false;
            });
          }).map((entry) {
            final reportId = entry.key;
            final messages = entry.value as Map<dynamic, dynamic>? ?? {};
            final senderName = messages.isNotEmpty ? messages.values.first['senderName'] ?? 'Unknown' : 'Unknown';
            final hasUnreadMessages = messages.values.any((msg) {
              if (msg is Map<dynamic, dynamic>) {
                return msg['hasUnreadMessages']?.toString().toLowerCase() == 'true';
              }
              return false;
            });
            final isAdmin = messages.values.any((msg) {
              if (msg is Map<dynamic, dynamic>) {
                return msg['senderRole'] == 'admin'; // Ensure the role exists in Firebase data
              }
              return false;
            });

            return {
              'reportId': reportId,
              'senderName': senderName,
              'hasUnreadMessages': hasUnreadMessages,
              'isAdmin': isAdmin,
            };
          }).toList();

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                color: report['isAdmin'] ? Color(0xFFeb6958) : null, // Apply color if admin
                child: ListTile(
                  title: Text(
                    'Sender: ${report['senderName']}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  trailing: report['hasUnreadMessages']
                      ? const Icon(Icons.mark_chat_unread, color: Colors.red)
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationScreen(
                          name: 'Report ${report['reportId']}',
                          reportId: report['reportId'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
