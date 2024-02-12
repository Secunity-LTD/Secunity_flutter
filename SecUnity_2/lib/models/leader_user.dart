import 'package:secunity_2/models/UserModel.dart';

class LeaderUser {
  final String firstName;
  final String lastName;
  final String role;
  bool hasTeam = false;

  LeaderUser({
    required String uid,
    required this.firstName,
    required this.lastName,
    required this.role,
  });
}


