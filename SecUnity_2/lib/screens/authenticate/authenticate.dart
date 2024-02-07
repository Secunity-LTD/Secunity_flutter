import 'package:flutter/cupertino.dart';
import 'package:secunity_2/screens/authenticate/sign_in.dart';
import 'package:secunity_2/screens/authenticate/sign_up.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  void toggelView(){
    setState(()=> showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    if(showSignIn){
      return SignIn(toggelView: toggelView);
    }else{
      return SignUp(toggelView: toggelView);
    }
  }
}
