import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:secunity_2/constants/constants.dart';


class Loading extends StatelessWidget {
  // const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primary,
      child: Center(
        child: SpinKitDualRing(color: errorColor,
        size: 50.0),

      ),
    );
  }
}
