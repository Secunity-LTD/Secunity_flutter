import 'package:flutter/cupertino.dart';
import 'package:secunity_2/screens/authenticate/authenticate.dart';
import 'package:provider/provider.dart';
import 'package:secunity_2/screens/home/home.dart';

import 'models/UserModel.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

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
