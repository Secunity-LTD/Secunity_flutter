import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../services/auth_service.dart';
import '../Home/home.dart';
import '../../constants/signin_style.dart';
import 'sign_up.dart';

class SignUpGmail extends StatefulWidget {
  final Function toggleView;
  SignUpGmail({required this.toggleView});

  @override
  _SignUpGmailState createState() => _SignUpGmailState();
}

class _SignUpGmailState extends State<SignUpGmail> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String error = '';
  String firstName = '';
  String lastName = '';
  String dropdownValue = 'Role';
  String dropdownValueTeam = 'Type';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: SignStyles.backgroundColor1,
        elevation: 0.0,
        title: Text('complete details for SecUnity',
            style: TextStyle(fontSize: 18.00,)),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SignUp(toggleView: () {})),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: secondary,
              textStyle: TextStyle(fontSize: 20.0),
            ),
            icon: Icon(Icons.person),
            label: Text(
              'Sign Up',
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
          Form(
            key: _formKey, // Add this line
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              children: <Widget>[
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Enter a first name' : null,
                  onChanged: (value) {
                    setState(() => firstName = value);
                  },
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18 // Make the text bold
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18 // Make the text bold
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Enter a last name' : null,
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
                  items: <String>['Role', 'Medic', 'Sniper', 'Negev']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,

                      child: Text(
                        value,
                        style: value == 'Role' // Check if the value is 'Role'
                            ? TextStyle(
                          color:
                          Colors.white, // Set the color for 'Role'
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )
                            : TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10.0),
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
                  items: <String>['Type', 'Team leader', 'Crew member']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: value == 'Type' // Check if the value is 'Role'
                            ? TextStyle(
                          color:
                          Colors.white, // Set the color for 'Role'
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )
                            : TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
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
                      dynamic result = await _authService.SignUpGmail(firstName,
                          lastName, dropdownValue, dropdownValueTeam);
                      if (result == null) {
                        setState(() {
                          error = 'Please provide a valid email';
                          loading = false;
                        });
                      } else if (result == 1) {
                        setState(() {
                          error = 'The email is already in use';
                          loading = false;
                        });
                      } else {
                        // Navigator.pushReplacementNamed(context, '/sign_in');
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
                SizedBox(height: 12.0),
                Text(
                  error,
                  style: TextStyle(color: errorColor, fontSize: 14.0),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
