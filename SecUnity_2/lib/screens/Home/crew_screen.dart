// /screens/Home/crew_screen.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secunity_2/constants/leader_style.dart';
import 'package:secunity_2/models/crew_user.dart';
import 'package:secunity_2/models/team_model.dart';
import 'package:secunity_2/services/auth_service.dart';
import 'package:secunity_2/constants/crew_style.dart';
import 'package:secunity_2/services/crew_database.dart';
import 'package:secunity_2/services/team_service.dart';
import 'package:secunity_2/services/crew_team_service.dart';

class CrewScreen extends StatefulWidget {
  @override
  _CrewPageState createState() => _CrewPageState();
}

class _CrewPageState extends State<CrewScreen> {
  final TextEditingController squadNameController = TextEditingController();
  final AuthService _authService = AuthService();
  User? user = FirebaseAuth.instance.currentUser;
  List<List<TextEditingController>> taskControllers = [];
  String firstName = '';
  String teamName = '';
  bool isInPosition = false;
  bool _isLoading = true;
  bool _hasTeam = false;
  String crewUid = '';
  CrewDatabaseService? crewDatabaseService;

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
    _fetchData();
    crewDatabaseService = CrewDatabaseService(uid: user!.uid);
  }

  Future<void> _fetchData() async {
    try {
      // Fetch data here
      await _fetchTeamName();
      await _fetchUserName();
      await _initializeTaskControllers();
      await _loadTasks();
      await _hasATeam();
      print('Data fetching completed successfully');
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error if necessary
    } finally {
      setState(() {
        _isLoading =
            false; // Set loading to false when data fetching is complete
      });
    }
  }

  Future<void> _fetchTeamName() async {
    try {
      // Fetching squad ID where current user is the leader
      QuerySnapshot squadSnapshot = await FirebaseFirestore.instance
          .collection('squads')
          // where the current user's ID is in the members[] contains the current user's ID
          .where('members',
              arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (squadSnapshot.docs.isNotEmpty) {
        setState(() {
          teamName = squadSnapshot.docs.first['squad_name'];
        });
      }
    } catch (e) {
      print('Error fetching team name: $e');
    }
  }

  Future<void> _hasATeam() async {
    try {
      // Fetching squad ID where current user is the leader
      QuerySnapshot squadSnapshot = await FirebaseFirestore.instance
          .collection('squads')
          // where the current user's ID is in the members[] contains the current user's ID
          .where('members',
              arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (squadSnapshot.docs.isNotEmpty) {
        setState(() {
          _hasTeam = true;
        });
      }
    } catch (e) {
      print('Error checking if the user has a team: $e');
    }
  }

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
      print("enter toggle position");
      // Query Firestore to get the squad document where the current user is a member
      QuerySnapshot squadSnapshot = await FirebaseFirestore.instance
          .collection('squads')
          .where(
              'members.${FirebaseAuth.instance.currentUser!.uid}.requester_id',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (squadSnapshot.docs.isNotEmpty) {
        print("enter if squadSnapshot.docs.isNotEmpty");
        String squadId = squadSnapshot.docs.first.id;
        print("squadId: $squadId");
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

  Widget _buildTaskTextField(int dayIndex, int timeIndex) {
    return TextField(
      controller: taskControllers[dayIndex][timeIndex],
      style: TextStyle(color: Colors.white),
      enabled: false,
      maxLines: null,
      decoration: InputDecoration(
        hintText: '---',
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

  Future<void> _initializeTaskControllers() async {
    try {
      // Fetching squad ID where current user is the leader
      QuerySnapshot squadSnapshot = await FirebaseFirestore.instance
          .collection('squads')
          // where the current user's ID is in the members[] contains the current user's ID
          .where('members',
              arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (!squadSnapshot.docs.isNotEmpty) {
        taskControllers = List.generate(
            7, (_) => List.generate(3, (_) => TextEditingController()));
      }

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

  Future<void> _loadTasks() async {
    try {
      QuerySnapshot squadSnapshot = await FirebaseFirestore.instance
          .collection('squads')
          .where('members',
              arrayContains: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (squadSnapshot.docs.isNotEmpty) {
        String squadId = squadSnapshot.docs.first.id;
        DocumentSnapshot tasksSnapshot = await FirebaseFirestore.instance
            .collection('squad_tasks')
            .doc(squadId)
            .get();

        if (tasksSnapshot.exists && tasksSnapshot.data() != null) {
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

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    if (user != null) {
      crewUid = user.uid;
    }
    CrewDatabaseService crewDatabaseService = CrewDatabaseService(uid: crewUid);
    if (_isLoading) {
      // If loading, show a loading indicator with gradient background
      return Scaffold(
        backgroundColor: CrewStyles.backgroundColor1,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white, // Set color of the circular progress indicator
            ),
          ),
        ),
      );
    }
    return StreamBuilder<CrewUser>(
        stream: crewDatabaseService!.getCrewUserStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print("enter snapshot.hasData");
            final crewUser = snapshot.data!;
            print("crewUser.uid: ${crewUser.uid}");
            print("crewUser.firstName: ${crewUser.firstName}");
            print("crewUser.realTimeAlert: ${crewUser.realTimeAlert}");

            return FutureBuilder(
                future: crewDatabaseService.getCrewUserDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      CrewUser crewUser = snapshot.data as CrewUser;
                      print("crewUser: $crewUser");
                      print("crewUser.uid: ${crewUser.uid}");
                      print("crewUser.firstName: ${crewUser.firstName}");
                      print("crewUser.lastName: ${crewUser.lastName}");
                      print("crewUser.teamUid: ${crewUser.teamUid}");
                      print("crewUser.leaderUid: ${crewUser.leaderUid}");
                      print("crewUser.role: ${crewUser.role}");
                      return Scaffold(
                        body: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CrewStyles.backgroundColor1,
                                CrewStyles.backgroundColor2,
                                CrewStyles.backgroundColor3,
                                CrewStyles.backgroundColor4,
                                CrewStyles.backgroundColor5,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: ListView(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // top left text
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
                                      ), // Text color changed to white
                                      // top right button logout
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (_hasTeam)
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
                                      // Table for days and time periods
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
                                                      style: CrewStyles
                                                          .tableHeaderText)),
                                              Center(
                                                  child: Text('Morning',
                                                      style: CrewStyles
                                                          .tableHeaderText)),
                                              Center(
                                                  child: Text('Evening',
                                                      style: CrewStyles
                                                          .tableHeaderText)),
                                              Center(
                                                  child: Text('Night',
                                                      style: CrewStyles
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
                                                        style: CrewStyles
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
                                      const SizedBox(height: 14),
                                      // Big button for Real Time Alert
                                      ElevatedButton(
                                        onPressed: () {
                                          // Handle Real Time Alert button press
                                          TeamService(uid: crewUser.teamUid)
                                              .sendRealTimeAlert();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: crewUser
                                                  .realTimeAlert
                                              ? Colors.yellow
                                              : LeaderStyles.alertButtonColor,
                                        ), //Set button color to dark red
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              // Handle button press
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
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
                                              // TogglePosition();
                                              print("enter onPressd position");
                                              CrewTeamService crewTeamService =
                                                  CrewTeamService(
                                                      crewUser.teamUid);
                                              crewTeamService.updatePosition(
                                                  crewUser.uid!);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isInPosition
                                                  ? Colors.green
                                                  : const Color.fromARGB(
                                                      255, 41, 48, 96),
                                            ),
                                            child: const Text(
                                              'InPosition',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              // TogglePosition();
                                              // print("enter onPressd position");
                                              // CrewTeamService crewTeamService =
                                              //     CrewTeamService(
                                              //         crewUser.teamUid);
                                              // crewTeamService.updatePosition(
                                              //     crewUser.uid!);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  crewUser.realTimeAlert
                                                      ? Colors.red
                                                      : const Color.fromARGB(
                                                          255, 41, 48, 96),
                                            ),
                                            child: const Text(
                                              'Emergency',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      if (!_hasTeam)
                                        TextField(
                                          controller: squadNameController,
                                          style: TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            hintText:
                                                'Search for an Emergency Squad',
                                            hintStyle:
                                                TextStyle(color: Colors.white),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                      if (!_hasTeam)
                                        ElevatedButton(
                                          onPressed: () async {
                                            // Get the squad name entered by the user
                                            String squadName =
                                                squadNameController.text.trim();

                                            // Check if the squad name is not empty
                                            if (squadName.isNotEmpty) {
                                              try {
                                                // Query Firestore to check if a squad with the same name exists
                                                QuerySnapshot querySnapshot =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('requests')
                                                        .where('squad_name',
                                                            isEqualTo:
                                                                squadName)
                                                        .where('requester_id',
                                                            isEqualTo:
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid)
                                                        .where('status',
                                                            isEqualTo:
                                                                'pending')
                                                        .get();

                                                // If a pending request already exists
                                                if (querySnapshot
                                                    .docs.isNotEmpty) {
                                                  // Show an error message indicating that the user already has a pending request
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'You already have a pending request for this squad.'),
                                                      duration:
                                                          Duration(seconds: 2),
                                                    ),
                                                  );
                                                } else {
                                                  // Add a new request only if there is no pending request
                                                  // Query Firestore to check if a squad with the same name exists
                                                  QuerySnapshot leaderSnapshot =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('squads')
                                                          .where('squad_name',
                                                              isEqualTo:
                                                                  squadName)
                                                          .get();

                                                  // If a squad with the same name exists
                                                  if (leaderSnapshot
                                                      .docs.isNotEmpty) {
                                                    // Get the leader ID of the existing squad
                                                    String leaderId =
                                                        leaderSnapshot.docs
                                                            .first['leader'];

                                                    // Add a document to the "requests" collection to send a request to the leader
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('requests')
                                                        .add({
                                                      'squad_name': squadName,
                                                      'requester_id':
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid,
                                                      'leader_id': leaderId,
                                                      'status':
                                                          'pending', // Set the initial status of the request
                                                    });

                                                    // Show a success message or perform any other action
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Request sent successfully!'),
                                                        duration: Duration(
                                                            seconds: 2),
                                                      ),
                                                    );
                                                  } else {
                                                    // If a squad with the same name does not exist, show an error message
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'No squad with the same name found.'),
                                                        duration: Duration(
                                                            seconds: 2),
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
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Squad name cannot be empty.'),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
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
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return const Text("something went wrong");
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }

                // child:
                );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
