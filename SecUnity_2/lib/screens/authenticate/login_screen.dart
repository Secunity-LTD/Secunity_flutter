// ./screens/authenticate/login_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'register_screen.dart';

class  LoginScreen extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  // Text controllers and focus node
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void dispose(){
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future loginUser() async{
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(hintText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(hintText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: loginUser,
              child: Text('Login'),
            ),
            TextButton(
              child: Text("Don't have an account? Sign up"),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => RegisterScreen())
                );
              },
            )
          ],
        ),
      ),
    );
  }
}