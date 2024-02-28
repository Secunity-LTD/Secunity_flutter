import 'package:flutter/material.dart';
import 'package:secunity_2/constants/leader_style.dart';
import 'package:secunity_2/models/crew_user.dart';
import 'package:secunity_2/models/team_model.dart';
import 'package:secunity_2/services/team_service.dart';
import '../../constants/positions _style.dart';
import 'dart:ui';

class PositionScreen extends StatefulWidget {
  String teamUid;
  PositionScreen({Key? key, required this.teamUid}) : super(key: key);

  @override
  State<PositionScreen> createState() => PositionScreenState();
}

class PositionScreenState extends State<PositionScreen> {
  TeamService? teamService;
  bool _isLoading = false;
  //List<String> crewUids = [];

  @override
  void initState() {
    super.initState();
    teamService = TeamService(uid: widget.teamUid);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // If loading, show a loading indicator with gradient background
      return Scaffold(
        backgroundColor: PositionStyles.backgroundColor1,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white, // Set color of the circular progress indicator
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: PositionStyles.backgroundColor1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Positions'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              PositionStyles.backgroundColor1,
              PositionStyles.backgroundColor2,
              PositionStyles.backgroundColor3,
              PositionStyles.backgroundColor4,
              PositionStyles.backgroundColor5,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<Team>(
          stream: teamService!.getTeamStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final team = snapshot.data!;
              print("team.position: ${team.position}");

              return Column(
                children: [
                  Expanded(
                    child: FutureBuilder<List<CrewUser>>(
                      future: teamService!.getCrewList(team.position),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final crewList = snapshot.data!;
                          return ListView(
                            children: crewList
                                .map((crewUser) => buildPositionList(crewUser))
                                .toList(),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      teamService!.clearPositions();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LeaderStyles.buttonColor,
                    ),
                    child: Text(
                      'Clear Positions',
                      style:
                          LeaderStyles.buttonText, // Use buttonText style here
                    ),
                  ),
                ],
              );
            } else {
              print("No data");
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  // Widget for presenting crew member in the list
  Widget buildPositionList(CrewUser crewUser) {
    return ListTile(
      title: Text('${crewUser.firstName} ${crewUser.lastName}'),
      subtitle: Text(crewUser.role),
    );
  }
}
