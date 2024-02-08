import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:secunity_2/screens/Home/leader_screen.dart';
import 'package:secunity_2/screens/Home/crew_screen.dart';
import 'package:secunity_2/screens/authenticate/sign_in.dart';
import 'package:secunity_2/services/auth_service.dart';
import 'package:secunity_2/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:secunity_2/screens/authenticate/login_screen.dart';
import 'package:secunity_2/screens/authenticate/sign_in.dart';

import 'models/UserModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCT5mSQ3-Y-EKNJPUZzVdxgBk7U692fSwM",
      // authDomain: "your_auth_domain",
      projectId: "secu-24360",
      // storageBucket: "your_storage_bucket",
      messagingSenderId: "1095188614950",
      appId: "1:1095188614950:android:1d64fa09d1a0ecf70abbe7",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
        initialData: null,
        value: AuthService().onAuthStateChanged,
        builder: (context, snapshot) {
          return MaterialApp(
            // Set initial route to '/login'
            initialRoute: '/login',
            // Define routes
            routes: {
              '/login': (context) => SignIn(
                    toggelView: () {},
                  ),
              '/leader': (context) => LeaderScreen(),
              '/crew': (context) => CrewScreen(),
              // Add other routes here
            },
            home: Wrapper(),
          );
        });
  }
}
