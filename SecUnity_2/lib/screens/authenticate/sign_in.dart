import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:secunity_2/screens/Home/leader_screen.dart'; // Import LeaderScreen
import 'package:secunity_2/services/auth_service.dart';
import 'package:secunity_2/constants/constants.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({required this.toggleView});
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']); // Google Sign-In instance

  // text field state
  String error = "";
  String email = "test";
  String password = "test";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondary,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0.0,
        title: Text('Sign in to SecUnity'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              widget.toggleView();
            },
            style: TextButton.styleFrom(
              primary: secondary,
            ),
            icon: Icon(Icons.person),
            label: Text(
              'Sign Up',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'EMAIL',
                ),
                validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                onChanged: (value) {
                  setState(() => email = value);
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                validator: (value) => value!.length < 6
                    ? 'Enter a password 6+ characters long'
                    : null,
                obscureText: true,
                onChanged: (value) {
                  setState(() => password = value);
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                child: Text(
                  'Sign in',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic result = await _authService.signIn(email, password);
                    if (result == null) {
                      setState(() {
                        error = 'Could not sign in with the credentials';
                      });
                    } else {
                      // Navigate to LeaderScreen after successful sign-in
                      Navigator.pushReplacementNamed(context, '/leader');
                    }
                  }
                },
              ),
              SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: () {
                  _handleGoogleSignIn();
                },
                child: Text('Sign in with Google'),
              ),
              SizedBox(height: 12.0),
              Text(
                error,
                style: TextStyle(color: errorColor, fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to handle Google Sign-In with Firebase Authentication
  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          print('Google Sign-In successful. User UID: ${user.uid}');
          // Proceed with your application logic after successful sign-in
          // For example, you can navigate to a new screen or update UI
        } else {
          print('Google Sign-In failed.');
        }
      } else {
        print('Google Sign-In canceled.');
      }
    } catch (error) {
      print('Error signing in with Google: $error');
    }
  }
}
