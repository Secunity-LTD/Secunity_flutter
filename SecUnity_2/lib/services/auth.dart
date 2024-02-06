// this file responsible for authentication process
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secunity_2/models/user.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // // create user object based on Firebase user
  // MyUser? fromFirebaseToUser(UserCredential user){
  //
  //   return user != null? MyUser(uid: user.uid) : null;
  // }
  // create user object based on Firebase user
  MyUser? _userFromFirebaseUser(UserCredential userCredential) {
    User? user = userCredential.user;

    // Checking if the user is not null
    if (user != null) {
      return MyUser(
        uid: user.uid,
      );
    } else {
      return null;
    }
  }

  // sign in anon
  Future signInAnon() async {
    try {
      // UserCredential AuthResult result = await _auth.signInAnonymously();
      // User FirebaseUser  user = result.user;
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user as UserCredential);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

// sign in with email and password


// register with email and password

// sign out

}
