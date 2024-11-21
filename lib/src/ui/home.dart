import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safetynet/src/ui/report_list_screen.dart';
import 'package:safetynet/src/ui/signIn.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0933),
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,

        actions: <Widget>[
          IconButton(onPressed: () {},
              icon: const Icon(Icons.logout_outlined))
        ],

        leading: IconButton(onPressed: () {},
            icon: const Icon(Icons.help_outlined)),
        backgroundColor: const Color(0xFF0A0933),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Builder(
        builder: (context) {
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.01, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildOutlinedButton(0, 'All'),
                      buildOutlinedButton(1, 'Crimes'),
                      buildOutlinedButton(2, 'Missing persons'),
                    ],
                  ),
                  SizedBox(height: 20),
                  buildMissingPersonsSection(),
                  SizedBox(height: 20),
                  buildMissingPersonsSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildOutlinedButton(int index, String text) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedIndex = index;
        });

        if (text == 'Missing persons') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportListScreen()),
          );
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _selectedIndex == index ? const Color(0xFFeb6958) : Colors.transparent,
        side: const BorderSide(color: Color(0xFFeb6958), width: 2.0),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: Text(text),
    );
  }

  Widget buildMissingPersonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Missing Persons',
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 180,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('missing_person_reports')
                  .where('status', isEqualTo: 'approved')
                  .where('visibleToUsers', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No missing persons found", style: TextStyle(color: Colors.white)));
                }

                final reports = snapshot.data!.docs;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    var report = reports[index];
                    String name = report['missingPersonName'] ?? 'Unknown';
                    String imageUrl = report['imageUrl'] ?? '';

                    if (imageUrl.isEmpty) {
                      imageUrl = '';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          width: 160,
                          color: Colors.blueAccent.withOpacity(0.3),
                          child: Column(
                            children: [
                              Expanded(
                                child: imageUrl.isNotEmpty
                                    ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person, size: 80, color: Colors.grey),
                                )
                                    : const Icon(Icons.person, size: 80, color: Colors.grey),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  name,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.pushReplacement(
                      //         context,
                      //         MaterialPageRoute(builder: (context) => SignInPage()),
                      //   },
                      // ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
