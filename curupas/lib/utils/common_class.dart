import 'package:flutter/material.dart';

class CommonClass {
  static void hideKeyBoard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}