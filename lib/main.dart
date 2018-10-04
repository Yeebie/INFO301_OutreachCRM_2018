import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outreachcrm_app/LoginPage.dart';

void main() {
  runApp(new MyApp());
  print("\n");
  print("Outreach: Flutter Application");
  print("Branch:   Master");
  print("Build:    Sprint 3 Pre-Release | Master, UI_Pagination,"
      " UI_Development, domain_page merge");
  print("Task:     Merge Master & UI_Development's ContactPage");
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
