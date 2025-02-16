// TODO Implement this library.import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:secunity_2/constants/leader_style.dart';
import 'package:secunity_2/services/leader_database.dart';
import 'package:secunity_2/services/team_service.dart';

class CrewTeamService {
  TeamService teamService;

  // // collection reference
  // final CollectionReference teamCollection =
  //     FirebaseFirestore.instance.collection('squads');

  // Constructor
  CrewTeamService(String leaderUid)
      : teamService = TeamService(uid: leaderUid) {
    print("entered CrewTeamService constructor");
    print("teamUid: ${teamService.uid}");
  }

  // update position
  Future<void> updatePosition(String crewUid) async {
    try {
      return await teamService.updatePosition(crewUid);
    } catch (e) {
      print('Error updating position: $e');
    }
  }

  // Leave Team
  Future<void> unAssign(String crewUid) async {
    print("entered unAssign - CrewTeamService");
    try {
      return await teamService.deleteCrew(crewUid);
    } catch (e) {
      print('Error updating position: $e');
    }
  }
  // Send Real Time Alert
  Future<void> sendRealTimeAlert() async {
    try {
      return await teamService.sendRealTimeAlert();
    } catch (e) {
      print('Error updating position: $e');
    }
  }
}
