import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:secunity_2/constants/leader_style.dart';
import 'package:secunity_2/services/leader_database.dart';

class TeamService {
  String leaderUid;
  // collection reference
  final CollectionReference teamCollection =
      FirebaseFirestore.instance.collection('squads');

  TeamService({required this.leaderUid});

  Future createTeam(String squadName, String squadCity, context) async {
    print("entered createTeam");
    if (squadName.isNotEmpty && squadCity.isNotEmpty) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('squads')
            .where('name', isEqualTo: squadName)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          _showSnackBar('A squad with the same name already exists.', context);
        } else {
          await FirebaseFirestore.instance.collection('squads').add({
            'squad_name': squadName,
            'city': squadCity,
            'leader': leaderUid,
            'members': [],
            'alert': false,
            'position': [],
          });

          LeaderDatabaseService(uid: leaderUid).updateLeaderState(true);
          // QuerySnapshot querySnapUpdate = await FirebaseFirestore.instance
          // .collection("leaders")
          // .doc(leaderUid)
          // .update({'has a team': true});

          _showSnackBar('Squad created successfully!', context);
        }
      } catch (e) {
        print('Error creating squad: $e');
      }
    } else {
      _showSnackBar('Squad name and city cannot be empty.', context);
    }
  }

  void _showSnackBar(String message, context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: LeaderStyles.snackBarText),
        duration: Duration(seconds: 2),
      ),
    );
  }

/*
for each crew as function "in position"
when he activates the function, the crew will be added to the list of in position

*/

  // // Create new Team method
  //  void _createSquad(String squadName, String squadCity) async {
  //    if (squadName.isNotEmpty && squadCity.isNotEmpty) {
  //      try {
  //        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //            .collection('squads')
  //            .where('name', isEqualTo: squadName)
  //            .get();
  //
  //        if (querySnapshot.docs.isNotEmpty) {
  //          _showSnackBar('A squad with the same name already exists.');
  //        } else {
  //          await FirebaseFirestore.instance.collection('squads').add({
  //            'squad_name': squadName,
  //            'city': squadCity,
  //            'leader': FirebaseAuth.instance.currentUser!.uid,
  //            'members': [],
  //            'alert': false,
  //          });
  //          squadNameController.clear();
  //          setState(() {
  //            squadCreated = true;
  //          });
  //          _showSnackBar('Squad created successfully!');
  //        }
  //      } catch (e) {
  //        print('Error creating squad: $e');
  //      }
  //    } else {
  //      _showSnackBar('Squad name and city cannot be empty.');
  //    }
  //  }
}
