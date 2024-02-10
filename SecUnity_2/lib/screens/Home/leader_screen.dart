// /screens/Home/leader_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderStyles {
  static const TextStyle headerText = TextStyle(
    color: Colors.white,
    fontSize: 20,
  );

  static const TextStyle dropdownItemText = TextStyle(
    color: Colors.white,
  );

  static const TextStyle tableHeaderText = TextStyle(
    color: Colors.white,
  );

  static const TextStyle snackBarText = TextStyle(
    color: Colors.white,
  );

  static const TextStyle buttonText = TextStyle(
    // Define buttonText TextStyle
    color: Colors.white,
  );

  static const Color buttonColor = Color.fromARGB(255, 41, 48, 96);

  static const Color backgroundColor1 = Color.fromARGB(255, 130, 120, 200);
  static const Color backgroundColor2 = Color.fromARGB(255, 70, 80, 150);
  static const Color backgroundColor3 = Color.fromARGB(255, 50, 70, 130);
  static const Color backgroundColor4 = Color.fromARGB(255, 30, 52, 100);
  static const Color backgroundColor5 = Color.fromARGB(255, 9, 13, 47);

  static const Color alertButtonColor = Color.fromARGB(255, 139, 0, 0);
}

class LeaderScreen extends StatefulWidget {
  @override
  _LeaderPageState createState() => _LeaderPageState();
}

class _LeaderPageState extends State<LeaderScreen> {
  final TextEditingController squadNameController = TextEditingController();
  final TextEditingController squadCityController = TextEditingController();
  bool squadCreated = false;
  List<QueryDocumentSnapshot> joinRequests = [];
  List<List<TextEditingController>> taskControllers = [];

  @override
  void initState() {
    super.initState();
    _checkIfLeader();
    _fetchJoinRequests();
    _initializeTaskControllers();
  }

  void _checkIfLeader() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('squads')
        .where('leader', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      squadCreated = querySnapshot.docs.isNotEmpty;
    });
  }

  void _fetchJoinRequests() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('leader_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('status', isEqualTo: 'pending')
        .get();

    setState(() {
      joinRequests = querySnapshot.docs;
    });
  }

  void _initializeTaskControllers() {
    taskControllers = List.generate(7, (_) => []);
    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < 3; j++) {
        taskControllers[i].add(TextEditingController());
      }
    }
  }

  void _acceptJoinRequest(QueryDocumentSnapshot request) async {
    try {
      QuerySnapshot squadSnapshot = await FirebaseFirestore.instance
          .collection('squads')
          .where('squad_name', isEqualTo: request['squad_name'])
          .get();

      if (squadSnapshot.docs.isNotEmpty) {
        DocumentSnapshot squadDoc = squadSnapshot.docs.first;
        await squadDoc.reference.update({
          'members': FieldValue.arrayUnion([request['requester_id']])
        });
        await request.reference.update({'status': 'accepted'});
        _fetchJoinRequests();
        _showSnackBar('Join request accepted successfully!');
      } else {
        print('Squad document not found.');
      }
    } catch (e) {
      print('Error accepting join request: $e');
    }
  }

  void _denyJoinRequest(QueryDocumentSnapshot request) async {
    try {
      await request.reference.update({'status': 'denied'});
      _fetchJoinRequests();
      _showSnackBar('Join request denied successfully!');
    } catch (e) {
      print('Error denying join request: $e');
    }
  }

  Widget _buildJoinRequestsDropdown() {
    return Column(
      children: [
        Text(
          'Join Requests',
          style: LeaderStyles.headerText,
        ),
        DropdownButton<QueryDocumentSnapshot>(
          onChanged: (request) async {
            if (request != null) {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Join Request'),
                  content:
                      Text('Do you want to accept or deny this join request?'),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          {_acceptJoinRequest(request), Navigator.pop(context)},
                      child:
                          Text('Accept', style: LeaderStyles.dropdownItemText),
                    ),
                    TextButton(
                      onPressed: () => {
                        _denyJoinRequest(request),
                        Navigator.pop(context),
                      },
                      child: Text('Deny', style: LeaderStyles.dropdownItemText),
                    ),
                  ],
                ),
              );
            }
          },
          items: joinRequests.map((request) {
            return DropdownMenuItem<QueryDocumentSnapshot>(
              value: request,
              child: Text(
                request['requester_id'],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _createSquad(String squadName, String squadCity) async {
    if (squadName.isNotEmpty && squadCity.isNotEmpty) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('squads')
            .where('name', isEqualTo: squadName)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          _showSnackBar('A squad with the same name already exists.');
        } else {
          await FirebaseFirestore.instance.collection('squads').add({
            'squad_name': squadName,
            'city': squadCity,
            'leader': FirebaseAuth.instance.currentUser!.uid,
            'members': [],
            'alert': false,
          });
          squadNameController.clear();
          setState(() {
            squadCreated = true;
          });
          _showSnackBar('Squad created successfully!');
        }
      } catch (e) {
        print('Error creating squad: $e');
      }
    } else {
      _showSnackBar('Squad name and city cannot be empty.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: LeaderStyles.snackBarText),
        duration: Duration(seconds: 2),
      ),
    );
  }

  bool _isEditing = false;

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              LeaderStyles.backgroundColor1,
              LeaderStyles.backgroundColor2,
              LeaderStyles.backgroundColor3,
              LeaderStyles.backgroundColor4,
              LeaderStyles.backgroundColor5,
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
                const Text(
                  'Hello',
                  style: LeaderStyles.headerText,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LeaderStyles.buttonColor,
                  ),
                  child: const Text(
                    'Logout',
                    style: LeaderStyles.headerText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                _toggleEdit();
                // Handle button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LeaderStyles.buttonColor,
              ),
              child: const Text(
                'Edit',
                style: LeaderStyles.buttonText, // Use buttonText style here
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.5),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                  },
                  border: TableBorder.all(color: Colors.white),
                  children: [
                    const TableRow(
                      children: [
                        Center(
                            child: Text('Days',
                                style: LeaderStyles.tableHeaderText)),
                        Center(
                            child: Text('Morning',
                                style: LeaderStyles.tableHeaderText)),
                        Center(
                            child: Text('Evening',
                                style: LeaderStyles.tableHeaderText)),
                        Center(
                            child: Text('Night',
                                style: LeaderStyles.tableHeaderText)),
                      ],
                    ),
                    for (var dayIndex = 0; dayIndex < 7; dayIndex++)
                      TableRow(
                        children: [
                          Center(
                              child: Text('Monday',
                                  style: LeaderStyles.tableHeaderText)),
                          _buildTaskTextField(dayIndex, 0),
                          _buildTaskTextField(dayIndex, 1),
                          _buildTaskTextField(dayIndex, 2),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {
                    // Handle Real Time Alert button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LeaderStyles.alertButtonColor,
                  ),
                  child: const Text(
                    'Real Time Alert',
                    style: LeaderStyles.buttonText, // Use buttonText style here
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Handle button press
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LeaderStyles.buttonColor,
                      ),
                      child: const Text(
                        'Positions',
                        style: LeaderStyles
                            .buttonText, // Use buttonText style here
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle button press
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LeaderStyles.buttonColor,
                      ),
                      child: const Text(
                        'Crew Requests',
                        style: LeaderStyles
                            .buttonText, // Use buttonText style here
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                squadCreated
                    ? _buildJoinRequestsDropdown()
                    : Row(
                        children: [
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
                          ElevatedButton(
                            onPressed: () {
                              _createSquad(squadNameController.text.trim(),
                                  squadCityController.text.trim());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LeaderStyles.buttonColor,
                            ),
                            child: const Text(
                              'Create',
                              style: LeaderStyles
                                  .buttonText, // Use buttonText style here
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTextField(int dayIndex, int timeIndex) {
    return TextField(
      controller: taskControllers[dayIndex][timeIndex],
      style: TextStyle(color: Colors.white),
      enabled: _isEditing,
      decoration: InputDecoration(
        hintText: 'Enter task',
        hintStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
