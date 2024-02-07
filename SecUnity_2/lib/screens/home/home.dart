import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../services/auth_service.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    return Scaffold(
      backgroundColor: secondary,
      appBar: AppBar(
        title: const Text('Lumei Digital'),
        backgroundColor: primary,
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person),
            style: TextButton.styleFrom(
              foregroundColor: secondary,
            ),
            label: Text('Sign out'),
            onPressed: ()async {
              await _authService.signOut();
            },
          )
        ],
      ),

    );
  }

}
