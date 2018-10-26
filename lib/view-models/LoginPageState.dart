import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreachcrm_app/views/LoginPageView.dart';

class MyLoginPage extends StatefulWidget {
  @override
  LoginPageView createState() => new LoginPageView();
}

abstract class MyLoginPageState extends State<MyLoginPage> {
  @protected
  int counter = 0;

  @protected
  void incrementCounter() {
    setState(() {
      counter++;
    });
  }
}