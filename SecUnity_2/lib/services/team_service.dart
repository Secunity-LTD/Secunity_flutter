import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:secunity_2/constants/leader_style.dart';
import 'package:secunity_2/services/leader_database.dart';

class TeamService {
  String squadUid;
  // String? squadUid;  // collection reference
  final CollectionReference teamCollection =
      FirebaseFirestore.instance.collection('squads');

  TeamService({required this.squadUid});

  // Future<String?> createTeam(
  //     String squadName, String squadCity, context) async {
  //   print("entered createTeam");
  //   if (squadName.isNotEmpty && squadCity.isNotEmpty) {
  //     try {
  //       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //           .collection('squads')
  //           .where('name', isEqualTo: squadName)
  //           .get();

  //       if (querySnapshot.docs.isNotEmpty) {
  //         _showSnackBar('A squad with the same name already exists.', context);
  //       } else {
  //         DocumentReference documentReference = await teamCollection.add({
  //           'squad_name': squadName,
  //           'city': squadCity,
  //           'leader': leaderUid,
  //           'members': [],
  //           'position': [],
  //           'alert': false,
  //         });
  //         this.squadUid = documentReference.id;
  //         print("squadUid: $squadUid");
  //         LeaderDatabaseService(uid: leaderUid).updateLeaderState(true);
  //         _showSnackBar('Squad created successfully!', context);
  //         // Return the document ID
  //         return documentReference.id;
  //       }
  //     } catch (e) {
  //       print('Error creating squad: $e');
  //     }
  //   } else {
  //     _showSnackBar('Squad name and city cannot be empty.', context);
  //   }
  // }

  void _showSnackBar(String message, context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: LeaderStyles.snackBarText),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // in Position
  Future<void> updatePosition(String crewUid) async {
    print("entered updatePosition - TeamService");
    print("squadUid: $squadUid");
    await teamCollection.doc(squadUid).update({
      'position': FieldValue.arrayUnion([crewUid]),
    });
    print('crewUid appended to position successfully: $crewUid');
  }
}
