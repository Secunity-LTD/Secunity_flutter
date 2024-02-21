import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:secunity_2/models/team_model.dart';

class TeamService {
  String uid;
  // String? squadUid;  // collection reference
  final CollectionReference teamCollection =
      FirebaseFirestore.instance.collection('squads');

  TeamService({required this.uid});

  StreamController<Team> _teamController = StreamController<Team>.broadcast();

  Stream<Team> get teamStream => _teamController.stream;

  void dispose() {
    _teamController.close();
  }

  FutureOr<Team> getTeamDetails() async {
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
}
