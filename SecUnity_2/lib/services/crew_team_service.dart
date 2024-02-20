// TODO Implement this library.import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:secunity_2/constants/leader_style.dart';
import 'package:secunity_2/services/leader_database.dart';
import 'package:secunity_2/services/team_service.dart';


class CrewTeamService {
  late TeamService teamService;
  
  // // collection reference
  // final CollectionReference teamCollection =
  //     FirebaseFirestore.instance.collection('squads');

  // Constructor
  CrewTeamService(String leaderUid) {
    print("entered CrewTeamService constructor");
    teamService = TeamService(squadUid: leaderUid);
    print("teamUid: ${teamService.squadUid}");
  } 


  // update position
  Future<void> updatePosition(String crewUid) async {
    print("entered updatePosition");
    try {
      return await teamService.updatePosition(crewUid);
    } catch (e) {
      print('Error updating position: $e');
    }
  }

}