import 'package:flutter/material.dart';
import 'package:secunity_2/constants/leader_style.dart';
import 'package:secunity_2/models/crew_user.dart';
import 'package:secunity_2/models/team_model.dart';
import 'package:secunity_2/services/team_service.dart';

class CrewMembersScreen extends StatefulWidget {
  String teamUid;
  CrewMembersScreen({super.key, required this.teamUid});

  @override
  State<CrewMembersScreen> createState() => CrewMembersScreenState();
}

class CrewMembersScreenState extends State<CrewMembersScreen> {
  TeamService? teamService;
  // List<String> crewUids = [];

  @override
  void initState() {
    super.initState();
    teamService = TeamService(uid: widget.teamUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crew Members'),
        backgroundColor: Colors.blue[900],
      ),
      body: StreamBuilder<Team>(
          stream: teamService!.getTeamStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final team = snapshot.data!;
              print("team.position: ${team.position}");

              return Column(
                children: [
                  Expanded(
                    child: FutureBuilder<List<CrewUser>>(
                      future: teamService!.getCrewList(team.members),
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
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      teamService!.clearAllCrew();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LeaderStyles.buttonColor,
                    ),
                    child: Text(
                      'Delete all crew',
                      style:
                          LeaderStyles.buttonText, // Use buttonText style here
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  // Widget for present crew member in the list
  Widget buildPositionList(CrewUser crewUser) {
    return ListTile(
      title: Text('${crewUser.firstName} ${crewUser.lastName}'),
      subtitle: Text(crewUser.role),
      trailing: const Icon(Icons.delete),
      onTap: () {

       teamService!.deleteCrew(crewUser.uid!);
      },
    );
  }
}
