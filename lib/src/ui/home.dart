import 'package:flutter/material.dart';
import 'package:safetynet/src/ui/report_list_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Color(0xFF0A0933),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
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
            buildScrollableSection('Crimes', 'assets/logo.png'),
            SizedBox(height: 20),
            buildScrollableSection('Missing Persons', 'assets/logo.png'),
          ],
        ),
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
        backgroundColor: _selectedIndex == index ? Color(0xFFeb6958) : Colors.transparent,
        side: BorderSide(color: Color(0xFFeb6958), width: 2.0),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: Text(text),
    );
  }

  Widget buildScrollableSection(String label, String placeholderImageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            label,
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      width: 160,
                      color: Colors.blueAccent.withOpacity(0.3),
                      child: Image.asset(
                        placeholderImageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
