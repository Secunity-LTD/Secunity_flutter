import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secunity_2/models/crew_user.dart';

class CrewDatabaseService {
  final String uid;
  // User? user = FirebaseAuth.instance.currentUser;
  CrewDatabaseService({required this.uid});
  // collection reference
  final CollectionReference crewCollection =
      FirebaseFirestore.instance.collection('crew');

  // // Fetch crew user data
  // Future<CrewUser> getCrewUserDetails() async {
  //   dynamic snapshot = crewCollection.doc(uid);
  //   final crewUser = snapshot.docs.map((e) => CrewUser.fromSnapshot(e)).single;
  //   return await crewUser;
  // }

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
    });
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
}
