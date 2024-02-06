import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:secunity_2/screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  runApp(MyApp());
  await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login Demo',
      home: LoginScreen(),
    );
  }
}