// import 'package:firebase_auth/firebase_auth.dart';
//
// class UserService {
//   User user;
//
//   UserService({required this.user})
// }
//
// // Inside a function or a widget
// User? getCurrentUser() {
//   User? user = FirebaseAuth.instance.currentUser;
//
//   if (user != null) {
//     String uid = user.uid;
//     print('User UID: $uid');
//     return user;
//   } else {
//     print('No user signed in.');
//     return null;
//   }
// }