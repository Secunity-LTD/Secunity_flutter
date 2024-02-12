class UserModel {
  final String uid;

  UserModel({required this.uid});
}

class UserData{
  final String uid;
  final String firstName;
  final String lastName;
  final String role;

  UserData({required this.uid, required this.firstName, required this.lastName, required this.role});
}