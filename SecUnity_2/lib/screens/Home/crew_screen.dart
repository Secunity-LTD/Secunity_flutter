// ./screens/Home/crew_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CrewScreen extends StatefulWidget {
  @override
  _CrewPageState createState() => _CrewPageState();
}

class _CrewPageState extends State<CrewScreen> {
  // Text controllers and focus node

  // Helper function to build a checkbox for each time period
  Widget _buildCheckbox(String text) {
    return Checkbox(
      value: false, // Set initial checkbox value
      onChanged: (value) {
        // Handle checkbox state changes
      },
    );
  }

  bool isInPosition = false;

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
                    ),
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
                        'Requests',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Toggle the state variable
                          isInPosition = !isInPosition;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInPosition
                            ? Colors
                                .green // Change color to green when isInPosition is true
                            : const Color.fromARGB(255, 41, 48,
                                96), // Dark red when isInPosition is false
                      ),
                      child: const Text(
                        'InPosition',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search for an Emergency Squad',
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
                    'Ask for joining',
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
