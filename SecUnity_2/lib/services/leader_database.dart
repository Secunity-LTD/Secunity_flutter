import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secunity_2/constants/leader_style.dart';
import 'package:secunity_2/models/UserModel.dart';
import 'package:flutter/material.dart';
// import 'package:secunity_2/services/team_database.dart';

import '../models/leader_user.dart';

class LeaderDatabaseService {
  final String uid;
  LeaderDatabaseService({required this.uid});
  // collection reference
  final CollectionReference leadersCollection =
      FirebaseFirestore.instance.collection('leaders');

  final CollectionReference teamCollection =
      FirebaseFirestore.instance.collection('squads');

  Future insertUserToData(
      String firstName, String lastName, String role) async {
    return await leadersCollection.doc(uid).set({
      'first name': firstName,
      'last name': lastName,
      'role': role,
      'has a team': false,
      'team uid': '',
    });
  }

  // Future updateUserData(String firstName, String lastName, String role) async {
  //   return await leadersCollection.doc(uid).set({
  //     'first name': firstName,
  //     'last name': lastName,
  //     'role': role,
  //   });
  // }

  Future updateLeaderState(bool state) async {
    print("entered updateLeaderState");
    // String? squadId = await getDocumentIdByLeaderUid(uid);
    // print('squadId: $squadId');
    return await leadersCollection.doc(uid).update({
      'has a team': state,
      // 'team uid': squadId,
    });
  }

  Future<String?> getDocumentIdByLeaderUid(String leaderUid) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('squads')
          .where('leader', isEqualTo: leaderUid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming there is only one document with the given leaderUid
        return querySnapshot.docs.first.id;
      } else {
        return null; // No matching document found
      }
    } catch (e) {
      print("Error getting document ID: $e");
      return null;
    }
  }

  Future updateLeaderTeam(String squadId) async {
    print("entered updateLeaderTeam");
    return await leadersCollection.doc(uid).update({
      'team uid': squadId,
    });
  }

  Future<String?> createTeam(
      String squadName, String squadCity, context) async {
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
          DocumentReference documentReference = await teamCollection.add({
            'squad_name': squadName,
            'city': squadCity,
            'leader': uid,
            'members': [],
            'position': [],
            'alert': false,
          });
          // this.squadUid = documentReference.id;
          // print("squadUid: $squadUid");
          LeaderDatabaseService(uid: uid).updateLeaderState(true);
          _showSnackBar('Squad created successfully!', context);
          // Return the document ID
          return documentReference.id;
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

  // get user details
  Future<LeaderUser> getLeaderUserDetails() async {
    try {
      DocumentSnapshot<Object?> snapshot = await leadersCollection.doc(uid).get();

      if (snapshot.exists) {
        // If the document exists, create a CrewUser object from the snapshot
        return LeaderUser.fromSnapshot(
            snapshot as DocumentSnapshot<Map<String, dynamic>>);
      } else {
        // If the document does not exist, return a default or handle accordingly
        print('Document with UID $uid does not exist');
        return LeaderUser(
          uid: uid,
          firstName: '',
          lastName: '',
          role: '',
          hasTeam: '',
          teamUid: '',
        );
      }
    } catch (e) {
      // Handle errors
      print("Error getting crew user details: $e");
      // You might want to throw an exception or handle it in a way that suits your app's needs
      return LeaderUser(
          uid: uid,
          firstName: '',
          lastName: '',
          role: '',
          hasTeam: '',
          teamUid: '',
        );
    }
  }

  // Update user data
  Future<void> updateLeaderUserData(LeaderUser leaderUser) async {
    await leadersCollection.doc(uid).update(leaderUser.toJson());
  }

  // // user data from snapshots
  // UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
  //   Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
  //
  //   if (data == null) {
  //     // Handle the case where there's no data in the snapshot
  //     // You can return a default UserData or throw an exception, depending on your requirements
  //     return UserData(uid: uid, firstName: '', lastName: '', role: '');
  //   }
  //
  //   return UserData(
  //     uid: uid,
  //     firstName: data['first name'] ?? '',
  //     lastName: data['last name'] ?? '',
  //     role: data['role'] ?? '', // 'role' is now a String
  //   );
  // }
  // user data from snapshots
  // UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
  //   // Check if the snapshot contains data and data exists
  //   if (snapshot.exists) {
  //     Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  //
  //     // Access data using keys
  //     String firstName = data['first name'] ?? '';
  //     String lastName = data['last name'] ?? '';
  //     String role = data['role'] ?? '';
  //
  //     return UserData(
  //       uid: uid,
  //       firstName: firstName,
  //       lastName: lastName,
  //       role: role,
  //     );
  //   } else {
  //     // Handle the case where the document doesn't exist
  //     return UserData(uid: uid, firstName: '', lastName: '', role: '');
  //   }
  // }

  // user data from snapshots
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    // Check if the snapshot contains data and data exists
    // if (snapshot.exists) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    // Access data using keys
    String firstName = data['first name'] ?? '';
    String lastName = data['last name'] ?? '';
    String role = data['role'] ?? '';
    bool hasTeam = data['has a team'] ?? '';

    return UserData(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      role: role,
      hasTeam: hasTeam,
    );
    // } else {
    // Handle the case where the document doesn't exist
    // return UserData(
    //     uid: uid, firstName: '', lastName: '', role: '', hasTeam: false);
    // }
  }

  // // get user doc stream
  // Stream<LeaderUser> get userData {
  //   return leadersCollection.doc(uid).snapshots()
  //       .map(_userDataFromSnapshot);
  // }

  // // get user doc stream
  // Stream<DocumentSnapshot> get userData {
  //   return leadersCollection.doc(uid).snapshots()
  //       .map(_userDataFromSnapshot);
  // }
// get user doc stream
  Stream<UserData>? get userData {
    return leadersCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }
}
