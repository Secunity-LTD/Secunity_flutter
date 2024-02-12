import 'package:secunity_2/models/UserModel.dart';

class CrewUser extends UserModel{
  final String firstName;
  final String lastName;
  final String role;
  bool hasTeam = false;

  CrewUser({
    required String uid,
    required this.firstName,
    required this.lastName,
    required this.role,
  }) : super(uid: uid);
}