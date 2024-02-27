import 'dart:ui';

import 'package:flutter/material.dart';

class SignStyles {
  static TextStyle headerText = TextStyle(
    fontSize: 20,
    color: Colors.white,
    shadows: [
      Shadow(
        blurRadius: 5,
        color: Colors.black,
        offset: Offset(3, 3),
      ),
    ],
  );

  static TextStyle dropdownItemText = TextStyle(
    color: Colors.white,
  );

  static TextStyle tableHeaderText = TextStyle(
    color: Colors.white,
  );

  static TextStyle snackBarText = TextStyle(
    color: Colors.white,
  );

  static TextStyle buttonText = TextStyle(
    color: Colors.white,
  );

  static Color buttonColor = Color.fromARGB(255, 41, 48, 96);

  static Color backgroundColor1 = Color.fromARGB(255, 130, 120, 200);
  static Color backgroundColor2 = Color.fromARGB(255, 70, 80, 150);
  static Color backgroundColor3 = Color.fromARGB(255, 50, 70, 130);
  static Color backgroundColor4 = Color.fromARGB(255, 30, 52, 100);
  static Color backgroundColor5 = Color.fromARGB(255, 9, 13, 47);

  static Color alertButtonColor = Color.fromARGB(255, 139, 0, 0);
}
