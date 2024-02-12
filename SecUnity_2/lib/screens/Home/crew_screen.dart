// /screens/Home/crew_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:secunity_2/services/auth_service.dart';

class CrewScreen extends StatefulWidget {
  @override
  _CrewPageState createState() => _CrewPageState();
}

class _CrewPageState extends State<CrewScreen> {
  final TextEditingController squadNameController = TextEditingController();
  final AuthService _authService = AuthService();
  String firstName = '';

  // Helper function to build a checkbox for each time period
  Widget _buildCheckbox(String text) {
    return Checkbox(
      value: false, // Set initial checkbox value
      onChanged: (value) {
        // Handle checkbox state changes
      },
    );
  }

  void initState() {
    super.initState();
    _fetchUserName();
  }

  bool isInPosition = false;

  Future<void> _fetchUserName() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('crew')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          firstName = userSnapshot['first name'];
        });
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  void TogglePosition() async {
    try {
      // Query Firestore to get the squad document where the current user is a member
      QuerySnapshot squadSnapshot = await FirebaseFirestore.instance
          .collection('squads')
          .where('members.requester_id',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (squadSnapshot.docs.isNotEmpty) {
        String squadId = squadSnapshot.docs.first.id;

        // Get the reference to the squad document
        DocumentReference squadRef =
            FirebaseFirestore.instance.collection('squads').doc(squadId);

        // Get the current members array
        DocumentSnapshot squadDoc = await squadRef.get();
        List<dynamic> members =
            (squadDoc.data() as Map<String, dynamic>)['members'];

        // Find the index of the current user's ID in the members array
        int index = members.indexWhere((element) =>
            element['requester_id'] == FirebaseAuth.instance.currentUser!.uid);

        if (index != -1) {
          // Update the status for the current user
          members[index]['status'] =
              isInPosition ? 'In Position' : 'Not In Position';

          // Create a new map with the updated members array
          Map<String, dynamic> updatedData = {'members': members};

          // Update the 'members' field in the squad document
          await squadRef.update(updatedData);
          print('Position updated successfully!');
        } else {
          print('User not found in the members array.');
        }
      } else {
        print('You are not a member of any squad.');
      }

      setState(() {
        isInPosition = !isInPosition;
      });
    } catch (e) {
      print('Error: $e');
    }
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
                Text(
                  'Hello $firstName !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ), // Text color changed to white
                // top right button logout
                ElevatedButton(
                  onPressed: () async {
                    // Sign out the current user
                    _authService.signOut(context);

                    // Navigate to the login screen
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
                        TogglePosition();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInPosition
                            ? Colors.green
                            : const Color.fromARGB(255, 41, 48, 96),
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
                TextField(
                  controller: squadNameController,
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
                  onPressed: () async {
                    // Get the squad name entered by the user
                    String squadName = squadNameController.text.trim();

                    // Check if the squad name is not empty
                    if (squadName.isNotEmpty) {
                      try {
                        // Query Firestore to check if a squad with the same name exists
                        QuerySnapshot querySnapshot = await FirebaseFirestore
                            .instance
                            .collection('requests')
                            .where('squad_name', isEqualTo: squadName)
                            .where('requester_id',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .where('status', isEqualTo: 'pending')
                            .get();

                        // If a pending request already exists
                        if (querySnapshot.docs.isNotEmpty) {
                          // Show an error message indicating that the user already has a pending request
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'You already have a pending request for this squad.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          // Add a new request only if there is no pending request
                          // Query Firestore to check if a squad with the same name exists
                          QuerySnapshot leaderSnapshot = await FirebaseFirestore
                              .instance
                              .collection('squads')
                              .where('squad_name', isEqualTo: squadName)
                              .get();

                          // If a squad with the same name exists
                          if (leaderSnapshot.docs.isNotEmpty) {
                            // Get the leader ID of the existing squad
                            String leaderId =
                                leaderSnapshot.docs.first['leader'];

                            // Add a document to the "requests" collection to send a request to the leader
                            await FirebaseFirestore.instance
                                .collection('requests')
                                .add({
                              'squad_name': squadName,
                              'requester_id':
                                  FirebaseAuth.instance.currentUser!.uid,
                              'leader_id': leaderId,
                              'status':
                                  'pending', // Set the initial status of the request
                            });

                            // Show a success message or perform any other action
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Request sent successfully!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            // If a squad with the same name does not exist, show an error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('No squad with the same name found.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        // Handle any errors
                        print('Error: $e');
                      }
                    } else {
                      // Show an error message if the squad name is empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Squad name cannot be empty.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
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
