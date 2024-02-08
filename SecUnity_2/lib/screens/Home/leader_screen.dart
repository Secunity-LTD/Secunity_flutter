import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderScreen extends StatefulWidget {
  @override
  _LeaderPageState createState() => _LeaderPageState();
}

class _LeaderPageState extends State<LeaderScreen> {
  final TextEditingController squadNameController = TextEditingController();
  final TextEditingController squadCityController = TextEditingController();

  void _createSquad(String squadName, String squadCity) async {
    print("Squad name: $squadName"); // Print squad name for debugging
    print("Leader id: ${FirebaseAuth.instance.currentUser!.uid}");
    // Validate if squad name is not empty
    if (squadName.isNotEmpty && squadCity.isNotEmpty) {
      try {
        // Check if a squad with the same name already exists
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('squads')
            .where('name', isEqualTo: squadName)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // If a squad with the same name already exists, show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('A squad with the same name already exists.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Add the squad data to Firestore
          await FirebaseFirestore.instance.collection('squads').add({
            'squad_name': squadName,
            'city': squadCity,
            'leader': FirebaseAuth.instance.currentUser!.uid,
            'members': [],
          });
          // Clear the text field after squad is created
          squadNameController.clear();
          // Show a success message or perform any other action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Squad created successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // Handle any errors that occur during squad creation
        print('Error creating squad: $e');
      }
    } else {
      // Show an error message if squad name is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Squad name and city cannot be empty.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Helper function to build a checkbox for each time period
  Widget _buildCheckbox(String text) {
    return Checkbox(
      value: false, // Set initial checkbox value
      onChanged: (value) {
        // Handle checkbox state changes
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 130, 120, 200),
              Color.fromARGB(255, 70, 80, 150),
              Color.fromARGB(255, 50, 70, 130),
              Color.fromARGB(255, 30, 52, 100),
              Color.fromARGB(255, 9, 13, 47),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // top left text
                const Text(
                  'Hello',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ), // Text color changed to white
                // top right button logout
                ElevatedButton(
                  onPressed: () async {
                    // Sign out the current user
                    await FirebaseAuth.instance.signOut();
                    // Navigate to the login screen
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      41,
                      48,
                      96,
                    ), // Set button color to yellow
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                // Handle button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  255,
                  41,
                  48,
                  96,
                ), // Set button color to dark red
              ),
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Column for days table, Real Time Alert button, and additional buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Table for days and time periods
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1), // Make the first column flexible
                    1: FlexColumnWidth(1), // Make the second column flexible
                    2: FlexColumnWidth(1), // Make the third column flexible
                    3: FlexColumnWidth(1), // Make the fourth column flexible
                  },
                  border: TableBorder.all(
                      color: Colors.white), // Add borders to the table
                  children: [
                    // Table header row
                    const TableRow(
                      children: [
                        Center(
                            child: Text('Days',
                                style: TextStyle(color: Colors.white))),
                        Center(
                            child: Text('Morning',
                                style: TextStyle(color: Colors.white))),
                        Center(
                            child: Text('Evening',
                                style: TextStyle(color: Colors.white))),
                        Center(
                            child: Text('Night',
                                style: TextStyle(color: Colors.white))),
                      ],
                    ),
                    // Build rows
                    for (var day in [
                      'Monday',
                      'Tuesday',
                      'Wednesday',
                      'Thursday',
                      'Friday',
                      'Saturday',
                      'Sunday'
                    ])
                      TableRow(
                        children: [
                          Center(
                              child: Text(day,
                                  style: TextStyle(color: Colors.white))),
                          _buildCheckbox('Morning'),
                          _buildCheckbox('Evening'),
                          _buildCheckbox('Night'),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                // Big button for Real Time Alert
                ElevatedButton(
                  onPressed: () {
                    // Handle Real Time Alert button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      139,
                      0,
                      0,
                    ), // Set button color to dark red
                  ),
                  child: const Text(
                    'Real Time Alert',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Additional buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Handle button press
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          41,
                          48,
                          96,
                        ), // Set button color to dark red
                      ),
                      child: const Text(
                        'Positions',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle button press
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          41,
                          48,
                          96,
                        ), // Set button color to dark red
                      ),
                      child: const Text(
                        'Crew Requests',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Left text field (2/3 of available space)
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: TextField(
                          controller: squadNameController,
                          style: TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Create an Emergency Squad',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Right text field (1/3 of available space)
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: squadCityController,
                        style: TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'City',
                          hintStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    String squadName = squadNameController.text.trim();
                    String squadCity = squadCityController.text.trim();
                    print("Squad name from controller: $squadCity");
                    _createSquad(squadName, squadCity);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      41,
                      48,
                      96,
                    ), // Set button color to dark red
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
