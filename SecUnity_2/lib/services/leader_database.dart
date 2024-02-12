import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secunity_2/models/UserModel.dart';
// import 'package:secunity_2/services/team_database.dart';

import '../models/leader_user.dart';

class LeaderDatabaseService {
  final String uid;
  LeaderDatabaseService({required this.uid});
  // collection reference
  final CollectionReference leadersCollection =
      FirebaseFirestore.instance.collection('leaders');

  Future insertUserToData(
      String firstName, String lastName, String role) async {
    return await leadersCollection.doc(uid).set({
      'first name': firstName,
      'last name': lastName,
      'role': role,
      'has a team': false
    });
  }

  Future updateUserData(String firstName, String lastName, String role) async {
    return await leadersCollection.doc(uid).set({
      'first name': firstName,
      'last name': lastName,
      'role': role,
    });
  }

  Future updateLeaderState(bool state) async {
    return await leadersCollection.doc(uid).update({
      'has a team': state,
    });
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
