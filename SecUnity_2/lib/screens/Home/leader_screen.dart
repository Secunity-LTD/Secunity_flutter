import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secunity_2/models/leader_user.dart';
import 'package:secunity_2/models/team_model.dart';
import 'package:secunity_2/screens/home/positions_screen.dart';
import 'package:secunity_2/screens/leader/crew_members.dart';
import 'package:secunity_2/screens/leader/positions.dart';
import 'package:secunity_2/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:secunity_2/models/userModel.dart';
import 'package:secunity_2/services/crew_database.dart';
import 'package:secunity_2/services/leader_database.dart';

import '../../constants/leader_style.dart';
import '../../services/team_service.dart';

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
  String firstName = '';
  String teamName = '';
  bool _isLoading = true;
  LeaderDatabaseService? leaderDatabaseService;

  @override
  void initState() {
    super.initState();
    _fetchData();
    leaderDatabaseService = LeaderDatabaseService(uid: user!.uid);
  }

  Future<void> _fetchData() async {
    await _fetchTeamName();
    await _checkIfLeader();
    await _fetchJoinRequests();
    await _initializeTaskControllers();
    await _loadTasks();
    await _fetchUserName();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchTeamName() async {
    try {
      QuerySnapshot SquadSnapshot = await FirebaseFirestore.instance
          .collection('squads')
          .where('leader', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (SquadSnapshot.docs.isNotEmpty) {
        setState(() {
          teamName = SquadSnapshot.docs.first['squad_name'];
        });
      }
    } catch (e) {
      print('Error fetching team name: $e');
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

  Future<void> _fetchUserName() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('leaders')
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

  Future<void> _checkIfLeader() async {
    // check if 'has a team' field is true in the leader's document
    DocumentSnapshot leaderSnapshot = await FirebaseFirestore.instance
        .collection('leaders')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (leaderSnapshot.exists) {
      bool hasTeam = leaderSnapshot['has a team'];
      if (hasTeam) {
        setState(() {
          squadCreated = hasTeam;
        });
      }
    }
  }

  Future<void> _fetchJoinRequests() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('leader_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('status', isEqualTo: 'pending')
        .get();

    setState(() {
      joinRequests = querySnapshot.docs;
    });
  }

  Future<void> _initializeTaskControllers() async {
    try {
      // Fetching squad ID where current user is the leader
      QuerySnapshot squadSnapshot = await FirebaseFirestore.instance
          .collection('squads')
          .where('leader', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      // Initialize the taskControllers list if it's null or empty
      if (taskControllers.isEmpty) {
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
      print("squadSnapshot: $squadSnapshot");

      if (squadSnapshot.docs.isNotEmpty) {
        DocumentSnapshot squadDoc = squadSnapshot.docs.first;
        print("squadDoc: $squadDoc");
        dynamic crewuid = request['requester_id'];
        print("crewuid: $crewuid");
        await squadDoc.reference.update({
          'members': FieldValue.arrayUnion([request['requester_id']])
        });
        // CrewDatabaseService _crewDatabaseService = CrewDatabaseService(uid: crewuid);
        // print(FirebaseAuth.instance.currentUser!.uid);
        CrewDatabaseService(uid: crewuid)
            .updateTeamUid(FirebaseAuth.instance.currentUser!.uid);

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
        FutureBuilder<List<DropdownMenuItem<QueryDocumentSnapshot>>>(
          future: _fetchJoinRequestsDropdownItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return DropdownButton<QueryDocumentSnapshot>(
                onChanged: (request) async {
                  if (request != null) {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Join Request'),
                        content: Text(
                            'Do you want to accept or deny this join request?'),
                        actions: [
                          TextButton(
                            onPressed: () => {
                              _acceptJoinRequest(request),
                              Navigator.pop(context)
                            },
                            child: Text('Accept',
                                style: LeaderStyles.dropdownItemText),
                          ),
                          TextButton(
                            onPressed: () => {
                              _denyJoinRequest(request),
                              Navigator.pop(context),
                            },
                            child: Text('Deny',
                                style: LeaderStyles.dropdownItemText),
                          ),
                        ],
                      ),
                    );
                  }
                },
                items: snapshot.data!,
              );
            }
          },
        ),
      ],
    );
  }

  Future<List<DropdownMenuItem<QueryDocumentSnapshot>>>
      _fetchJoinRequestsDropdownItems() async {
    List<DropdownMenuItem<QueryDocumentSnapshot>> dropdownItems = [];
    for (var request in joinRequests) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('crew')
          .doc(request['requester_id'])
          .get();
      final userData = userSnapshot.data() as Map<String, dynamic>;
      final firstName = userData[
          'first name']; // Assuming the firstName field exists in your user document
      final lastName = userData[
          'last name']; // Assuming the lastName field exists in your user document
      final fullName = '$firstName $lastName';
      dropdownItems.add(
        DropdownMenuItem<QueryDocumentSnapshot>(
          value: request,
          child: Text(fullName),
        ),
      );
    }
    return dropdownItems;
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
    LeaderDatabaseService leaderDatabaseService =
        LeaderDatabaseService(uid: leaderUid);
    if (_isLoading) {
      // If loading, show a loading indicator with gradient background
      return Scaffold(
        backgroundColor:
            LeaderStyles.backgroundColor1, // Set Scaffold background color
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white, // Set color of the circular progress indicator
            ),
          ),
        ),
      );
    }
    return StreamBuilder<LeaderUser>(
        stream: leaderDatabaseService!.getLeaderUserStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print("enter snapshot.hasData");
            final leaderUser = snapshot.data!;
            print("leaderUser.uid: ${leaderUser.uid}");
            print("leaderUser.firstName: ${leaderUser.firstName}");
            print("leaderUser.realTimeAlert: ${leaderUser.realTimeAlert}");

            return FutureBuilder(
                future: leaderDatabaseService.getLeaderUserDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      LeaderUser leaderUser = snapshot.data as LeaderUser;
                      print("leaderUser: $leaderUser");
                      print("leaderUser.uid: ${leaderUser.uid}");
                      print("leaderUser.firstName: ${leaderUser.firstName}");
                      print("leaderUser.lastName: ${leaderUser.lastName}");
                      print("leaderUser.teamUid: ${leaderUser.teamUid}");
                      print("leaderUser.role: ${leaderUser.role}");
                      return Scaffold(
                        backgroundColor: Colors
                            .transparent, // Set Scaffold background color to transparent
                        body: Container(
                          width: double
                              .infinity, // Ensure Container fills the screen width
                          height: double
                              .infinity, // Ensure Container fills the screen height
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
                          child: ListView(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Hello $firstName !',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 5,
                                              color: Colors.black,
                                              offset: Offset(3, 3),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          _fetchData();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape:
                                              CircleBorder(), // Make the button circular
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              10.0), // Adjust padding to make it smaller
                                          child: Icon(
                                            Icons.refresh,
                                            color: Colors.black,
                                            size:
                                                20, // Adjust icon size if needed
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          _authService.signOut(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              LeaderStyles.buttonColor,
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
                                      style: LeaderStyles
                                          .buttonText, // Use buttonText style here
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (squadCreated)
                                        Center(
                                          child: Text(
                                            '$teamName Schedule',
                                            style: TextStyle(
                                              fontSize: 30,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 5,
                                                  color: Colors.black,
                                                  offset: Offset(3, 3),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      Table(
                                        columnWidths: {
                                          0: FlexColumnWidth(1.5),
                                          1: FlexColumnWidth(2),
                                          2: FlexColumnWidth(2),
                                          3: FlexColumnWidth(2),
                                        },
                                        border: TableBorder.all(
                                            color: Colors.white),
                                        children: [
                                          TableRow(
                                            children: [
                                              Center(
                                                  child: Text('Days',
                                                      style: LeaderStyles
                                                          .tableHeaderText)),
                                              Center(
                                                  child: Text('Morning',
                                                      style: LeaderStyles
                                                          .tableHeaderText)),
                                              Center(
                                                  child: Text('Evening',
                                                      style: LeaderStyles
                                                          .tableHeaderText)),
                                              Center(
                                                  child: Text('Night',
                                                      style: LeaderStyles
                                                          .tableHeaderText)),
                                            ],
                                          ),
                                          for (var dayIndex = 0;
                                              dayIndex < 7;
                                              dayIndex++)
                                            TableRow(
                                              children: [
                                                Center(
                                                    child: Text('Monday',
                                                        style: LeaderStyles
                                                            .tableHeaderText)),
                                                _buildTaskTextField(
                                                    dayIndex, 0),
                                                _buildTaskTextField(
                                                    dayIndex, 1),
                                                _buildTaskTextField(
                                                    dayIndex, 2),
                                              ],
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 14),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Handle Real Time Alert button press
                                          TeamService(uid: leaderUser.teamUid)
                                              .sendRealTimeAlert();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: leaderUser
                                                  .realTimeAlert
                                              ? Colors.yellow
                                              : LeaderStyles.alertButtonColor,
                                        ),
                                        child: Text(
                                          'Real Time Alert',
                                          style: LeaderStyles
                                              .buttonText, // Use buttonText style here
                                        ),
                                      ),
                                      SizedBox(height: 14),
                                      if (squadCreated)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                // Navigate to the Position screen and pass squadUid
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PositionScreen(
                                                            teamUid: leaderUser
                                                                .teamUid),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    LeaderStyles.buttonColor,
                                              ),
                                              child: Text(
                                                'Positions',
                                                style: LeaderStyles
                                                    .buttonText, // Use buttonText style here
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                // Navigate to the Position screen and pass squadUid
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        CrewMembersScreen(
                                                            teamUid: leaderUser
                                                                .teamUid),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    LeaderStyles.buttonColor,
                                              ),
                                              child: Text(
                                                'Crew Members List',
                                                style: LeaderStyles
                                                    .buttonText, // Use buttonText style here
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                // Handle button press
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    LeaderStyles.buttonColor,
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
                                                    padding: EdgeInsets.only(
                                                        right: 8.0),
                                                    child: TextField(
                                                      controller:
                                                          squadNameController,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Create an Emergency Squad',
                                                        hintStyle: TextStyle(
                                                            color:
                                                                Colors.white),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: TextField(
                                                    controller:
                                                        squadCityController,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                    decoration: InputDecoration(
                                                      hintText: 'City',
                                                      hintStyle: TextStyle(
                                                          color: Colors.white),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    String? teamUid =
                                                        await leaderDatabaseService
                                                            .createTeam(
                                                                // --------------------------------------
                                                                squadNameController
                                                                    .text
                                                                    .trim(),
                                                                squadCityController
                                                                    .text
                                                                    .trim(),
                                                                context);
                                                    // add teamUID to the leader's document
                                                    if (teamUid != null) {
                                                      leaderDatabaseService
                                                          .updateLeaderState(
                                                              true);

                                                      leaderDatabaseService
                                                          .updateLeaderTeam(
                                                              teamUid);
                                                      print(
                                                          "teamUid: $teamUid");
                                                    }
                                                    // sync the data
                                                    _fetchData();

                                                    setState(() {
                                                      squadCreated = true;
                                                    });
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        LeaderStyles
                                                            .buttonColor,
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
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      return Center(
                        child: Text('No data found.'),
                      );
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                });
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _buildTaskTextField(int dayIndex, int timeIndex) {
    return TextField(
      controller: taskControllers[dayIndex][timeIndex],
      style: TextStyle(color: Colors.white, fontSize: 15),
      enabled: _isEditing,
      maxLines: null,
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
  Future<void> _loadTasks() async {
    try {
      QuerySnapshot squadSnapshot = await FirebaseFirestore.instance
          .collection('squads')
          .where('leader', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      print("is not empty: ${squadSnapshot.docs.isNotEmpty}");
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
