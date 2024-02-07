// this file responsible for authentication process
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secunity_2/models/user.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;


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
      // UserCredential
      final userCredential = await _auth.signInAnonymously();
      // User
      final user = userCredential.user;
      return _userFromFirebaseUser(userCredential);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

// sign in with email and password


// register with email and password

// sign out

}
