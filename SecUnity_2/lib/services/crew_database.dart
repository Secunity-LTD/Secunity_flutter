import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secunity_2/models/crew_user.dart';

class CrewDatabaseService {
  final String uid;
  CrewDatabaseService({required this.uid});
  // collection reference
  final CollectionReference crewCollection =
      FirebaseFirestore.instance.collection('crew');

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

  Future updateUserData(String firstName, String lastName, String role) async {
    return await crewCollection.doc(uid).set({
      'first name': firstName,
      'last name': lastName,
      'role': role,
      // 'team': ,
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
