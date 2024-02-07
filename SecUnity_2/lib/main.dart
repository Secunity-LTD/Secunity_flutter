import 'package:flutter/material.dart';
import 'screens/authenticate/login_screen.dart';
import 'screens/Home/leader_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login Demo',
      home: LeaderScreen(),
    );
  }
}
