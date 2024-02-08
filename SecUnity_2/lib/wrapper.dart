import 'package:secunity_2/models/userModel.dart';
import 'package:secunity_2/screens/authenticate/authenticate.dart';
import 'package:secunity_2/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel?>(context);
    if (userModel == null){
      return Authenticate();
    }else{
      return Home();
    }
  }
}