import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outreach/view-models/splash_state.dart';
import 'util/routes.dart';

void main() {
  runApp(new MyApp());
  print("\n");
  print("Outreach: Flutter Application");
  print("Branch:   refactor");
  print("Build:    REFACTOR");
  print("\n");
}

class MyApp extends StatelessWidget {
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
      home: new Splash(),
      routes: routes,
    );
  }
}

