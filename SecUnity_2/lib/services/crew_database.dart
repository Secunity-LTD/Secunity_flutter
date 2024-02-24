import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secunity_2/models/crew_user.dart';

class CrewDatabaseService {
  final String uid;
  // User? user = FirebaseAuth.instance.currentUser;
  CrewDatabaseService({required this.uid});
  // collection reference
  final CollectionReference crewCollection =
      FirebaseFirestore.instance.collection('crew');

  // get user details
  Future<CrewUser> getCrewUserDetails() async {
    try {
      DocumentSnapshot<Object?> snapshot = await crewCollection.doc(uid).get();

      if (snapshot.exists) {
        // If the document exists, create a CrewUser object from the snapshot
        return CrewUser.fromSnapshot(
            snapshot as DocumentSnapshot<Map<String, dynamic>>);
      } else {
        // If the document does not exist, return a default or handle accordingly
        print('Document with UID $uid does not exist');
        return CrewUser(
          uid: uid,
          firstName: '',
          lastName: '',
          role: '',
          leaderUid: '',
          teamUid: '',
          realTimeAlert: false,
        );
      }
    } catch (e) {
      // Handle errors
      print("Error getting crew user details: $e");
      // You might want to throw an exception or handle it in a way that suits your app's needs
      return CrewUser(
        uid: uid,
        firstName: '',
        lastName: '',
        role: '',
        leaderUid: '',
        teamUid: '',
        realTimeAlert: false,
      );
    }
  }

  // update user data
  Future<void> updateUserData(CrewUser crewUser) async {
    await crewCollection.doc(uid).update(crewUser.toJson());
  }

  Future inserteToUserData(
      String firstName, String lastName, String role) async {
    return await crewCollection.doc(uid).set({
      'first name': firstName,
      'last name': lastName,
      'role': role,
      'team uid': '',
      'leader uid': '',
      'real time alert': false
    });
  }

  // update alert status
  Future<void> updateAlertStatus() async {
    print("entered updateAlertStatus");
    CrewUser crewUser = await getCrewUserDetails();
    print("crewUser.uid: ${crewUser.uid}");
    print("crewUser.realTimeAlert: ${crewUser.realTimeAlert}");
    if (crewUser.realTimeAlert == false) {
      await crewCollection.doc(uid).update({
        'real time alert': true,
      });
    } else {
      await crewCollection.doc(uid).update({
        'real time alert': false,
      });
    }
    ;
  }

  Future updateTeamUid(String leaderUid) async {
    print("entered updateTeamUid");
    String? squadId = await getDocumentIdByLeaderUid(leaderUid);
    print('squadId: $squadId');
    return await crewCollection.doc(uid).update({
      'team uid': squadId,
      'leader uid': leaderUid,
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

  // Get Stream of Team
  Stream<CrewUser> getCrewUserStream() {
    return crewCollection.doc(uid).snapshots().map((snapshot) =>
        CrewUser.fromSnapshot(
            snapshot as DocumentSnapshot<Map<String, dynamic>>));
  }
}
