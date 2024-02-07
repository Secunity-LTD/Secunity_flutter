import 'package:firebase_auth/firebase_auth.dart';
import 'package:secunity_2/models/UserModel.dart';

class AuthService {

  final FirebaseAuth _auth =FirebaseAuth.instance;

  // auth change user stream
  Stream<UserModel?> get onAuthStateChanged{
    return _auth.authStateChanges()
    //.map((User? user) => _userModelFromFirebase(user));
        .map(_userModelFromFirebase);
  }

  // create an UserModel object based on Firebase User object
  UserModel? _userModelFromFirebase(User? user) {
    if(user != null){
      return UserModel(uid: user.uid);
    } else {
      return null;
    }
  }

  //sing in with email & password
  Future signIn(String email, String password) async{
    try{
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

  Future signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userModelFromFirebase(user);
    } catch(e){
      return null;
    }
  }

  //sing out
  Future signOut() async{
    try{
      return await _auth.signOut();
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }

}