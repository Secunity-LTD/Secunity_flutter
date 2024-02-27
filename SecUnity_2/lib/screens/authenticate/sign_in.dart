import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:secunity_2/screens/authenticate/sign_up.dart';
import 'package:secunity_2/services/auth_service.dart';
import 'package:secunity_2/constants/constants.dart';
import 'package:secunity_2/screens/home/home.dart';

import '../../constants/signin_style.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({required this.toggleView});
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // text field state
  String error = "";
  String email = "test";
  String password = "test";
  int type = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: SignStyles.backgroundColor1,
        elevation: 0.0,
        title: Text('Sign in to SecUnity'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignUp(toggleView: () {})),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: secondary,
              textStyle: TextStyle(fontSize: 20.0),
            ),
            icon: Icon(Icons.person),
            label: Text('Sign Up',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SignStyles.backgroundColor1,
                  SignStyles.backgroundColor2,
                  SignStyles.backgroundColor3,
                  SignStyles.backgroundColor4,
                  SignStyles.backgroundColor5,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/Secunity_Background.png"),
                  fit: BoxFit.none,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'EMAIL',
                      labelStyle: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22.0 // Make the text bold
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                        color: Colors.white,
                        width: 2.0, // Set the width to make it bold
                        )
                      ),
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
                      labelStyle: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22.0
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 2.0, // Set the width to make it bold
                          )
                      ),
                    ),
                    validator: (value) => value!.length < 6 ? 'Enter a password 6+ characters long' : null,
                    obscureText: true,
                    onChanged: (value) {
                      setState(() => password = value);
                    },
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          primary),
                    ),
                    child: Text(
                      'Sign in',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        dynamic result = await _authService.signIn(email, password);
                        if (result == null) {
                          setState(() {
                            error = 'Could not sign in with the credentials';
                          });
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Home(),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      dynamic result = await _authService.signInWithGoogle(context);
                      if (result == null) {
                        setState(() {
                          error = 'Could not sign in with the credentials';
                        });
                      } else {
                        User? firebaseUser = FirebaseAuth.instance.currentUser;
                        if (firebaseUser != null) {
                          String email = firebaseUser.email!;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Home(email: email, password: '123456'),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: Container(
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.google,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4.0),
                            Text(
                              'Sign in with Google',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
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
        ],
      ),
    );
  }


}


