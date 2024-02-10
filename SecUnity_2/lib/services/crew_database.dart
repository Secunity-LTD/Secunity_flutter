import 'package:cloud_firestore/cloud_firestore.dart';

class CrewDatabaseService {

  final String uid;
  CrewDatabaseService({required this.uid});
  // collection reference
  final CollectionReference crewCollection = FirebaseFirestore.instance.collection('crew');

  Future inserteToUserData(String firstName, String lastName, String role) async{
    return await crewCollection.doc(uid).set({
      'first name': firstName,
      'last name': lastName,
      'role': role,
    });
  }

  Future updateUserData(String firstName, String lastName, String role) async{
    return await crewCollection.doc(uid).set({
      'first name': firstName,
      'last name': lastName,
      'role': role,
    });
  }



}