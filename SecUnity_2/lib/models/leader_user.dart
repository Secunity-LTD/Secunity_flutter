import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secunity_2/models/UserModel.dart';

class LeaderUser {
  final String? uid;
  final String firstName;
  final String lastName;
  bool hasTeam = false;
  final String role;
  String teamUid;
  bool realTimeAlert = false;

  LeaderUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.role,
    required hasTeam,
    required this.teamUid,
    required this.realTimeAlert,
  });

  toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'has_team': hasTeam,
      'role': role,
      'team_uid': teamUid,
      'real time alert': realTimeAlert,
    };
  }

  factory LeaderUser.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? {}; // Handle nullable data
    return LeaderUser(
      uid: document.id,
      firstName:
          data["first name"] ?? "", // Provide default value or handle null
      lastName: data['last name'] ?? "", // Provide default value or handle null
      role: data['role'] ?? "", // Provide default value or handle null
      hasTeam: data['has a team'] ?? "", // Provide default value or handle null
      teamUid: data['team uid'] ?? "", // Provide default value or handle null
      realTimeAlert: data['real time alert'] ?? false,
    );
  }
}
