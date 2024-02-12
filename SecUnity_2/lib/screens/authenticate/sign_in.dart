import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:secunity_2/services/auth_service.dart';
import 'package:secunity_2/constants/constants.dart';
import 'package:secunity_2/screens/home/home.dart';

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
                    // Navigate to LeaderScreen after successful sign-in
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                        builder: (context) => Home(),
                        )
                      ,);
                    // Navigator.pushReplacementNamed(context, '/crew');
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Change button color to red
                ),
                child: Container(
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.google,
                          color: Colors.white, // Change icon color to white
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          'Sign in with Google',
                          style: TextStyle(
                              color:
                                  Colors.white), // Change text color to white
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
    );
  }
}
