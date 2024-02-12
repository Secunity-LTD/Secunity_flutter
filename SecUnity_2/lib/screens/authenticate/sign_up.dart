
import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../services/auth_service.dart';

class SignUp extends StatefulWidget {
  final Function toggleView;
  SignUp({required this.toggleView});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String email = '';
  String password = '';
  String confirmPassword = '';
  String error = '';
  String userType = '0';
  String firstName = '';
  String lastName = '';
  String dropdownValue = 'Role';
  String dropdownValueTeam = 'Type';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondary,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0.0,
        title: Text('Sign up to SecUnity'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              widget.toggleView();
            },
            style: TextButton.styleFrom(primary: secondary),
            icon: Icon(Icons.person),
            label: Text(
              'Sign In',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    body: Form(
      key: _formKey, // Add this line
        child: ListView(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        children: <Widget>[
          SizedBox(height: 10.0),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'First Name',
            ),
            validator: (value) => value!.isEmpty ? 'Enter a first name' : null,
            onChanged: (value) {
              setState(() => firstName = value);
            },
          ),

          SizedBox(height: 10.0),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Last Name',
            ),
            validator: (value) => value!.isEmpty ? 'Enter a last name' : null,
            onChanged: (value) {
              setState(() => lastName = value);
            },
          ),
          DropdownButton<String>(
            value: dropdownValue, // Default value
            onChanged: (String? newValue) {
              // Update dropdown value
              setState(() {
                dropdownValue = newValue!;
              });
              // Handle any other actions
              print(newValue);
            },
            items: <String>['Role','Medic', 'Sniper','Negev']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),


          SizedBox(height: 10.0),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Email',
            ),
            validator: (value) => value!.isEmpty ? 'Enter an email' : null,
            onChanged: (value) {
              setState(() => email = value);
            },
          ),
          SizedBox(height: 10.0),
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
          SizedBox(height: 10.0),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Confirm Password',
            ),
            validator: (value) {
              if (value != password) {
                return 'Passwords do not match';
              }
              return null;
            },
            obscureText: true,
            onChanged: (value) {
              setState(() => confirmPassword = value);
            },
          ),
          DropdownButton<String>(
            value: dropdownValueTeam, // Default value
            onChanged: (String? newValue) {
              // Update dropdown value
              setState(() {
                dropdownValueTeam = newValue!;
              });
              // Handle any other actions
              print(newValue);
            },
            items: <String>['Type','Team leader', 'Crew member']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),


          SizedBox(height: 10.0),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(primary),
            ),
            child: Text(
              'Sign up',
              style: TextStyle(color: secondary),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() => loading = true);
                dynamic result = await _authService.signUp(firstName, lastName, dropdownValue, email, password, dropdownValueTeam);
                if (result == null) {
                  setState(() {
                    error = 'Please provide a valid email';
                    loading = false;
                  });
                  print('change page 1');
                } else if (result == 1) {
                  setState(() {
                    error = 'The email is already in use';
                    loading = false;
                  });
                } else {
                  print('change page 2');
                  Navigator.pushReplacementNamed(context, '/sign_in');
                }
              }
            },
          ),

          SizedBox(height: 12.0),
          Text(
            error,
            style: TextStyle(color: errorColor, fontSize: 14.0),
          )
        ],
      ),
    ),
    );
  }
}
