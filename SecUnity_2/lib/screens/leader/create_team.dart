import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:secunity_2/services/team_service.dart';

import '../../constants/constants.dart';

class CreateTeam extends StatefulWidget {
  const CreateTeam({Key? key}) : super(key: key);

  @override
  _CreateTeamState createState() => _CreateTeamState();
}

class _CreateTeamState extends State<CreateTeam> {
  final _formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;
  String leaderUid = '';
  String name = '';
  String city = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    if (user != null) {
      leaderUid = user.uid;
    }
    final TeamService _teamService = TeamService(leaderUid: leaderUid);
    return Scaffold(
      backgroundColor: secondary,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0.0,
        title: Text('Create SecUnity Team'),
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
                  labelText: 'Team name',
                ),
                validator: (value) =>
                value!.isEmpty ? 'Enter team name' : null,
                onChanged: (value) {
                  setState(() => name = value);
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'City',
                ),
                validator: (value) => value!.isEmpty ? 'Enter city' : null,
                onChanged: (value) {
                  setState(() => city = value);
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                child: Text(
                  'Create team',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic result =
                    await _teamService.createTeam(name, city);
                    if (result == null) {
                      setState(() {
                        error = 'Could not create the team';
                      });
                    } else {
                      // Navigate to LeaderScreen after successful team creation
                      Navigator.pushReplacementNamed(context, '/leader');
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
