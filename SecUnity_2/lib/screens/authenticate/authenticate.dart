import 'package:flutter/cupertino.dart';
import 'package:secunity_2/screens/authenticate/sign_in.dart';
import 'package:secunity_2/services/auth.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SignIn(),
    );
  }
}
