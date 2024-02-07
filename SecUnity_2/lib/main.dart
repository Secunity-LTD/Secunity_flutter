import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:secunity_2/services/auth_service.dart';
import 'package:secunity_2/wrapper.dart';

import 'models/UserModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
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
            home: Wrapper(),
          );
        }
    );
  }
}