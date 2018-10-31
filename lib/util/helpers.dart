import 'package:flutter/material.dart';

class Util {
  static hideSoftKeyboard(BuildContext context) {
    // call this method here to hide soft keyboard
    FocusScope.of(context).requestFocus(new FocusNode());
  }
}