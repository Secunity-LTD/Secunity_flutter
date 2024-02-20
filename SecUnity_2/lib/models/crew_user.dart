import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secunity_2/models/UserModel.dart';

class CrewUser {
  final String? uid;
  final String firstName;
  final String lastName;
  final String role;
  String leaderUid;
  String teamUid;

  CrewUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.leaderUid,
    required this.teamUid,
  });

  toJson() {
    return {
      'first name': firstName,
      'last name': lastName,
      'role': role,
      'leader uid': leaderUid,
      'team uid': teamUid,
    };
  }

  // // Map CrewUser object from firebase snapshot
  // factory CrewUser.fromSnapshot(
  //     DocumentSnapshot<Map<String, dynamic>> document) {
  //   final data = document.data()!; // as Map<String, dynamic>;
  //   return CrewUser(
  //     uid: document.id,
  //     firstName: data["first name"],
  //     lastName: data['last name'],
  //     role: data['role'],
  //     leaderUid: data['leader uid'],
  //     teamUid: data['team uid'],
  //   );
  // }
  factory CrewUser.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
  final data = document.data() ?? {}; // Handle nullable data
  return CrewUser(
    uid: document.id,
    firstName: data["first name"] ?? "", // Provide default value or handle null
    lastName: data['last name'] ?? "", // Provide default value or handle null
    role: data['role'] ?? "", // Provide default value or handle null
    leaderUid: data['leader uid'] ?? "", // Provide default value or handle null
    teamUid: data['team uid'] ?? "", // Provide default value or handle null
  );
}

}
