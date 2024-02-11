import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secunity_2/services/auth_service.dart';

import '../../services/team_service.dart';

class LeaderStyles {
  static TextStyle headerText = TextStyle(
    color: Colors.white,
    fontSize: 20,
  );

  static TextStyle dropdownItemText = TextStyle(
    color: Colors.white,
  );

  static TextStyle tableHeaderText = TextStyle(
    color: Colors.white,
  );

  static TextStyle snackBarText = TextStyle(
    color: Colors.white,
  );

  static TextStyle buttonText = TextStyle(
    color: Colors.white,
  );

  static Color buttonColor = Color.fromARGB(255, 41, 48, 96);

  static Color backgroundColor1 = Color.fromARGB(255, 130, 120, 200);
  static Color backgroundColor2 = Color.fromARGB(255, 70, 80, 150);
  static Color backgroundColor3 = Color.fromARGB(255, 50, 70, 130);
  static Color backgroundColor4 = Color.fromARGB(255, 30, 52, 100);
  static Color backgroundColor5 = Color.fromARGB(255, 9, 13, 47);

  static Color alertButtonColor = Color.fromARGB(255, 139, 0, 0);
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
  final AuthService _authService = AuthService();
  User? user = FirebaseAuth.instance.currentUser;
  String leaderUid = '';

  @override
  void initState() {
    super.initState();
    _checkIfLeader();
    _fetchJoinRequests();
    _initializeTaskControllers();
    _loadTasks();
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

  void _initializeTaskControllers() async {
    try {
      // Fetching squad ID where current user is the leader
      QuerySnapshot squadSnapshot = await FirebaseFirestore.instance
          .collection('squads')
          .where('leader', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      // Initialize the taskControllers list if it's null or empty
      if (taskControllers == null || taskControllers.isEmpty) {
        taskControllers = List.generate(
            7, (_) => List.generate(3, (_) => TextEditingController()));
      }

      if (squadSnapshot.docs.isNotEmpty) {
        // Getting the ID of the first squad (assuming user can lead only one squad)
        String squadId = squadSnapshot.docs.first.id;

        for (int i = 0; i < 7; i++) {
          for (int j = 0; j < 3; j++) {
            String day = _getDayName(i);
            String time = _getTimeName(j);
            DocumentSnapshot taskSnapshot = await FirebaseFirestore.instance
                .collection('squad_tasks')
                .doc(
                    '$day-$time-$squadId') // Using squad ID in task document ID
                .get();

            if (taskSnapshot.exists) {
              Map<String, dynamic>? data =
                  taskSnapshot.data() as Map<String, dynamic>?;

              if (data != null && data.containsKey('task')) {
                taskControllers[i][j] =
                    TextEditingController(text: data['task']);
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error initializing task controllers: $e');
    }
  }

  String _getDayName(int index) {
    List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[index];
  }

  String _getTimeName(int index) {
    List<String> times = ['Morning', 'Evening', 'Night'];
    return times[index];
  }

  void _acceptJoinRequest(QueryDocumentSnapshot request) async {
    try {
      QuerySnapshot squadSnapshot = await FirebaseFirestore.instance
          .collection('squads')
          .where('squad_name', isEqualTo: request['squad_name'])
          .get();

      if (squadSnapshot.docs.isNotEmpty) {
        DocumentSnapshot squadDoc = squadSnapshot.docs.first;

        // Construct a map with key-value pairs
        Map<String, dynamic> memberData = {
          'requester_id': request['requester_id'],
          'status': 'Not In Position'
        };

        // Add the map to the 'members' array field using FieldValue.arrayUnion
        await squadDoc.reference.update({
          'members': FieldValue.arrayUnion([memberData])
        });

        // Update the status of the join request
        await request.reference.update({'status': 'accepted'});

        // Fetch and update join requests
        _fetchJoinRequests();

        // Show a snackbar message
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

  String getEditButtonText() {
    return _isEditing ? 'Save' : 'Edit';
  }

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    if (user != null) {
      leaderUid = user.uid;
    }
    final TeamService _teamService = TeamService(leaderUid: leaderUid);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hello',
                  style: LeaderStyles.headerText,
                ),
                ElevatedButton(
                  onPressed: () async {
                    _authService.signOut(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LeaderStyles.buttonColor,
                  ),
                  child: Text(
                    'Logout',
                    style: LeaderStyles.headerText,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                // check if the leader has already created a squad
                if (squadCreated) {
                  _toggleEdit();
                } else {
                  _showSnackBar('Create a squad first.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LeaderStyles.buttonColor,
              ),
              child: Text(
                getEditButtonText(),
                style: LeaderStyles.buttonText, // Use buttonText style here
              ),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Table(
                  columnWidths: {
                    0: FlexColumnWidth(1.5),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                  },
                  border: TableBorder.all(color: Colors.white),
                  children: [
                    TableRow(
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
                SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {
                    // Handle Real Time Alert button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LeaderStyles.alertButtonColor,
                  ),
                  child: Text(
                    'Real Time Alert',
                    style: LeaderStyles.buttonText, // Use buttonText style here
                  ),
                ),
                SizedBox(height: 14),
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
                      child: Text(
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
                      child: Text(
                        'Crew Requests',
                        style: LeaderStyles
                            .buttonText, // Use buttonText style here
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                squadCreated
                    ? _buildJoinRequestsDropdown()
                    : Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: TextField(
                                controller: squadNameController,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
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
                              decoration: InputDecoration(
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
                              _teamService.createTeam(squadNameController.text.trim(),
                                  squadCityController.text.trim());
                              // _createSquad(squadNameController.text.trim(),
                              //     squadCityController.text.trim());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LeaderStyles.buttonColor,
                            ),
                            child: Text(
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
      onChanged: (_) {
        if (_isEditing) {
          _saveTasks();
        }
      },
    );
  }

  // Function to save all tasks for the squad in a single document
  void _saveTasks() async {
    try {
      // Fetching squad ID where current user is the leader
      QuerySnapshot squadSnapshot = await FirebaseFirestore.instance
          .collection('squads')
          .where('leader', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (squadSnapshot.docs.isNotEmpty) {
        String squadId = squadSnapshot.docs.first.id;
        DocumentReference squadTasksRef =
            FirebaseFirestore.instance.collection('squad_tasks').doc(squadId);

        Map<String, dynamic> tasksData = {};
        for (int i = 0; i < 7; i++) {
          for (int j = 0; j < 3; j++) {
            String day = _getDayName(i);
            String time = _getTimeName(j);
            tasksData['$day-$time'] = taskControllers[i][j].text;
          }
        }

        await squadTasksRef.set(tasksData);
        _showSnackBar('Tasks saved successfully!');
      }
    } catch (e) {
      print('Error saving tasks: $e');
    }
  }

  // Function to load tasks for the squad when logging in
  void _loadTasks() async {
    try {
      QuerySnapshot squadSnapshot = await FirebaseFirestore.instance
          .collection('squads')
          .where('leader', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (squadSnapshot.docs.isNotEmpty) {
        String squadId = squadSnapshot.docs.first.id;
        DocumentSnapshot tasksSnapshot = await FirebaseFirestore.instance
            .collection('squad_tasks')
            .doc(squadId)
            .get();

        if (tasksSnapshot.exists) {
          Map<String, dynamic>? tasksData =
              tasksSnapshot.data() as Map<String, dynamic>?;

          if (tasksData != null) {
            for (int i = 0; i < 7; i++) {
              for (int j = 0; j < 3; j++) {
                String day = _getDayName(i);
                String time = _getTimeName(j);
                String taskKey = '$day-$time';

                if (tasksData.containsKey(taskKey)) {
                  taskControllers[i][j].text = tasksData[taskKey];
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }
}
