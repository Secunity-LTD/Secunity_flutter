import 'package:flutter/material.dart';
import 'package:secunity_2/screens/Home/leader_screen.dart';
import 'package:secunity_2/screens/Home/crew_screen.dart';
import 'package:secunity_2/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../authenticate/sign_up_gmail.dart';

class Home extends StatefulWidget {
  final String? email;
  final String? password;

  Home({this.email, this.password});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _navigateToInitialScreen();
  }

  Future<void> _navigateToInitialScreen() async {
    try {
      print("Tring to connect");
      // Query the 'leaders' collection to check if the user is a leader
      DocumentSnapshot leaderSnapshot = await FirebaseFirestore.instance
          .collection('leaders')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (leaderSnapshot.exists) {
        // User is a leader, navigate to LeaderScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LeaderScreen()),
        );
      } else {
        print("enter else for crew screen");
        // User is not a leader, check if they are a crew member
        DocumentSnapshot crewSnapshot = await FirebaseFirestore.instance
            .collection('crew')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

        if (crewSnapshot.exists) {
          print("enter crew exist");
          // User is a crew member, navigate to CrewScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CrewScreen()),
          );
        } else {
          // User not found in either 'leaders' or 'crew' collection
          // You may want to handle this case accordingly, e.g., navigate to a sign-in screen


          // If email and password are provided, perform a sign-in process
          if (widget.email != null && widget.password != null) {
            // Perform sign-in process using widget.email and widget.password
            // Example: AuthService.signIn(widget.email, widget.password);
            print(widget.email);
            print(widget.password);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignUpGmail(toggleView: (){})),
            );  
          } else {
            // Do something else if email and password are not provided
          }

          // MaterialPageRoute(builder: (context) => LeaderScreen());
          print("User not found in leaders or crew collection");
          print("Your ID is: ${FirebaseAuth.instance.currentUser!.uid}");

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => CrewScreen()),
          // );
        }
      }
    } catch (e) {
      print("Error navigating to initial screen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder widget for Home screen, you might want to customize it further
    return Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), // You can display a loader while navigating
      ),
    );
  }
}
