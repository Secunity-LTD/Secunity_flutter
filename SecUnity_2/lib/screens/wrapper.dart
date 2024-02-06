import 'package:flutter/cupertino.dart';
import 'package:secunity_2/screens/authenticate/authenticate.dart';
import 'package:secunity_2/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {

    // return either Home or Authenticate widget
    return Authenticate();
  }
}
