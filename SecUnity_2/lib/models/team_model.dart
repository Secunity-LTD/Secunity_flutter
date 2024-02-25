import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String uid;
  final String name;
  final String city;
  final String leaderUid;
  final List<String> members;
  final List<String> position;
  bool realTimeAlert = false;

  Team(this.uid, this.name, this.city, this.leaderUid, this.members,
      this.position, this.realTimeAlert);

  Map<String, dynamic> toJson() {
    return {
      'squad_name': name,
      'city': city,
      'leader': leaderUid,
      'members': members,
      'position': position,
      'real time alert': realTimeAlert,
    };
  }

  // Map Team object from firebase snapshot
  factory Team.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!; // as Map<String, dynamic>;
    return Team(
      document.id,
      data["squad_name"],
      data['city'],
      data['leader'],
      List<String>.from(data['members']),
      List<String>.from(data['position']),
      data['real time alert'],
    );
  }

  static Team fromJson(Map<String, dynamic> data) => Team(
        data['uid'],
        data['squad_name'],
        data['city'],
        data['leader'],
        List<String>.from(data['members']),
        List<String>.from(data['position']),
        data['real time alert'],
      );
}
