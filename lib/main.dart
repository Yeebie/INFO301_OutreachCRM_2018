import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outreachcrm_app/LoginPage.dart';
import 'package:outreachcrm_app/ContactPage.dart';
import 'package:outreachcrm_app/ViewContact.dart';

void main() {
  runApp(new MyApp());
  print("\n");
  print("Outreach: Flutter Application");
  print("Branch:   Navigator_Routes");
  print("Build:    Sprint 4 Pre-Release | Master & NavButton merge");
  print("Task:     Solve Logout Navigator issue");
  print("\n");
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return new MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Signika',
      ),
      home: LoginPage(
        loginFields: LoginFields(),
      ),
    );
  }
}
