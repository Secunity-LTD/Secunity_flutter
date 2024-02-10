import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_data.dart';

class LeaderDatabaseService {
  final String uid;
  LeaderDatabaseService({required this.uid});
  // collection reference
  final CollectionReference leadersCollection = FirebaseFirestore.instance.collection('leaders');

  Future insertUserToData(String firstName, String lastName, String role) async{
    return await leadersCollection.doc(uid).set({
      'first name': firstName,
      'last name': lastName,
      'role': role,
    });
  }

  Future updateUserData(String firstName, String lastName, String role) async{
    return await leadersCollection.doc(uid).set({
      'first name': firstName,
      'last name': lastName,
      'role': role,
    });
  }



  // user data from snapshots
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

    if (data == null) {
      // Handle the case where there's no data in the snapshot
      // You can return a default UserData or throw an exception, depending on your requirements
      return UserData(uid: uid, firstName: '', lastName: '', role: '');
    }

    return UserData(
      uid: uid,
      firstName: data['first name'] ?? '',
      lastName: data['last name'] ?? '',
      role: data['role'] ?? '', // 'role' is now a String
    );
  }

  // get user doc stream
  Stream<UserData> get userData {
    return leadersCollection.doc(uid).snapshots()
        .map(_userDataFromSnapshot);
  }
}
