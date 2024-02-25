import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:secunity_2/models/crew_user.dart';
import 'package:secunity_2/models/team_model.dart';
import 'package:secunity_2/services/crew_database.dart';
import 'package:secunity_2/services/leader_database.dart';

class TeamService {
  String uid;
  // String? squadUid;  // collection reference
  final CollectionReference teamCollection =
      FirebaseFirestore.instance.collection('squads');

  TeamService({required this.uid});

  Future<Team> getTeamDetails() async {
    print("entered getTeamDetails - TeamService");
    DocumentSnapshot<Object?> snapshot = await teamCollection.doc(uid).get();

    if (snapshot.exists) {
      print("enter snapshot.exists - TeamService");
      // If the document exists, create a CrewUser object from the snapshot
      return Team.fromSnapshot(
          snapshot as DocumentSnapshot<Map<String, dynamic>>);
    } else {
      // If the document does not exist, return a default or handle accordingly
      throw Exception('Unable to fetch team'); // Throw an exception
    }
  }

  // in Position
  Future<void> updatePosition(String crewUid) async {
    print("entered updatePosition - TeamService");
    print("squadUid: $uid");
    await teamCollection.doc(uid).update({
      'position': FieldValue.arrayUnion([crewUid]),
    });
    print('crewUid appended to position successfully: $crewUid');
  }

  // Present all crew members in crewUid List
  Future<List<CrewUser>> getCrewList(List<String> crewUids) async {
    print("entered getCrewList - TeamService");

    // Create CrewDatabaseService objects for each crew UID
    final List<CrewDatabaseService> crewServices =
        crewUids.map((crewUid) => CrewDatabaseService(uid: crewUid)).toList();
    // return list of CrewUser objects from each CrewDatabaseService
    return Future.wait(
        crewServices.map((crewService) => crewService.getCrewUserDetails()));
  }

  // Get Stream of Team
  Stream<Team> getTeamStream() {
    return teamCollection.doc(uid).snapshots().map((snapshot) =>
        Team.fromSnapshot(snapshot as DocumentSnapshot<Map<String, dynamic>>));
  }
  // Clear all positions array
  clearPositions() {
    print("entered clearPositions - TeamService");
    teamCollection.doc(uid).update({
      'position': [],
    });
    print('position cleared successfully');
  }

  // Clear all crew members array
  clearAllCrew() {
    print("entered clearPositions - TeamService");
    teamCollection.doc(uid).update({
      'members': [],
    });
    print('position cleared successfully');
  }

  deleteCrew(String crewUid) {
    print("entered deleteCrew - TeamService");
    teamCollection.doc(uid).update({
      'members': FieldValue.arrayRemove([crewUid]),
    });
    print('crewUid removed from members successfully: $crewUid');
  }

  Future<void> sendRealTimeAlert() async {
    print("entered sendRealTimeAlert - TeamService");
    Team team = await getTeamDetails();

    // Create CrewDatabaseService objects for each crew UID
    final List<CrewDatabaseService> crewServices = team.members
        .map((crewUid) => CrewDatabaseService(uid: crewUid))
        .toList();
    // Create LeaderDatabaseService objects for leader UID
    final LeaderDatabaseService leaderService =
        LeaderDatabaseService(uid: team.leaderUid);

    // updateAlertStatus for each crew member
    Future.wait(
        crewServices.map((crewService) => crewService.updateAlertStatus()));
    // updateAlertStatus for leader
    leaderService.updateAlertStatus();
    // updateAlertStatus for team
    updateAlertStatus();
  }

  // update alert status
  Future<void> updateAlertStatus() async {
    print("entered updateAlertStatus");
    Team team = await getTeamDetails();
    print("crewUser.uid: ${team.uid}");
    print("crewUser.realTimeAlert: ${team.realTimeAlert}");
    if (team.realTimeAlert == false) {
      await teamCollection.doc(uid).update({
        'real time alert': true,
      });
    } else {
      await teamCollection.doc(uid).update({
        'real time alert': false,
      });
    }
    ;
  }
}
