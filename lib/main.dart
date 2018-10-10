import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outreachcrm_app/LoginPage.dart';

void main() {
  runApp(new MyApp());
  print("\n");
  print("Outreach: Flutter Application");
  print("Branch:   API_Domain Check");
  print("Build:    Sprint 5 Bug Fixes | Domain Validation");
  print(
      "Task:     Checking Domain Page Validation");
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
