import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Team extends Equatable {
  final String uid;
  final String name;
  final String city;
  final String leaderUid;
  final List<String> members;
  final List<String> position;
  bool alert = false;

  Team(this.uid, this.name, this.city, this.leaderUid, this.members, this.position, this.alert);

  @override
  List<Object?> get props => [uid, name, city, leaderUid, members, position, alert];

  toJson() {
    return {
      'squad_name': name,
      'city': city,
      'leader': leaderUid,
      'members': members,
      'position': position,
      'alert': alert,
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
      data['alert'],
    );
  }
}
