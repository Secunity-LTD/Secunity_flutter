import 'package:firebase_auth/firebase_auth.dart';
import 'package:secunity_2/models/UserModel.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'crew_database.dart';
import 'leader_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // auth change user stream
  Stream<UserModel?> get onAuthStateChanged {
    return _auth
        .authStateChanges()
        //.map((User? user) => _userModelFromFirebase(user));
        .map(_userModelFromFirebase);
  }

  // create an UserModel object based on Firebase User object
  UserModel? _userModelFromFirebase(User? user) {
    if (user != null) {
      return UserModel(uid: user.uid);
    } else {
      return null;
    }
  }

  //sing in with email & password
  Future signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign in with Google
  Future signInWithGoogle(context) async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn(); 

      if (googleSignInAccount != null) { 
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential( 
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        UserCredential result = await _auth.signInWithCredential(credential);
        return _userModelFromFirebase(result.user);
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign up with email & password
  Future signUp(String firsName, String lastName, String dropdownValueTeam, String email,
      String password, String userType) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user!;
      // create a new document for the user with the uid
      if (userType == 'Team leader') {
        await LeaderDatabaseService(uid: user.uid)
            .insertUserToData(firsName, lastName, dropdownValueTeam);
      } else if (userType == 'Crew member'){
        await CrewDatabaseService(uid: user.uid)
            .inserteToUserData(firsName, lastName, dropdownValueTeam);
      }


      return _userModelFromFirebase(user);
    }
    // if the email exists return 1, else return null
    catch (e) {
      print(e.toString());
      if (e.toString().contains('email-already-in-use')) {
        return 1;
      }
      return null;
    }
  }

  //sign up with email & password
  Future SignUpGmail(String firsName, String lastName, String dropdownValueTeam, String userType) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // create a new document for the user with the uid
        if (userType == 'Team leader') {
          await LeaderDatabaseService(uid: user.uid)
              .insertUserToData(firsName, lastName, dropdownValueTeam);
        } else if (userType == 'Crew member') {
          await CrewDatabaseService(uid: user.uid)
              .inserteToUserData(firsName, lastName, dropdownValueTeam);
        }
      }
      return _userModelFromFirebase(user);
    }
    // if the email exists return 1, else return null
    catch (e) {
      print(e.toString());
      if (e.toString().contains('email-already-in-use')) {
        return 1;
      }
      return null;
    }
  }

  //sing out
  Future signOut(context) async {
    try {
      await _auth.signOut();
      Navigator.pushNamed(context, '/login');
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign in anonymously, it's an asynchronous task, it's going to return a future
  Future signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user!;
      return _userModelFromFirebase(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  
  
}
