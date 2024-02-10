import 'package:secunity_2/models/UserModel.dart';

class UserData extends UserModel {
  final String firstName;
  final String lastName;
  final String role;

  UserData({
    required String uid,
    required this.firstName,
    required this.lastName,
    required this.role,
  }) : super(uid: uid);
}