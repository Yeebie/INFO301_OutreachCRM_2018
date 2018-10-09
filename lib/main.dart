import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outreachcrm_app/LoginPage.dart';

void main() {
  runApp(new MyApp());
  print("\n");
  print("Outreach: Flutter Application");
  print("Branch:   Master");
  print("Build:    Sprint 4 Pre-Release | Aaron & Ben's Logout Functions");
  print(
      "Task:     Merge Master & Navigator_Routes, Colour Consistency, ViewContact Navigator Fix");
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
      debugShowCheckedModeBanner: false,
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
