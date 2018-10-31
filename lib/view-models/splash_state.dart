import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:outreach/views/SplashView.dart';

class Splash extends StatefulWidget {
  @override
  SplashView createState() => new SplashView();
}

abstract class SplashState extends State<Splash> {
  int _showSplashLengh = 3;

  Future checkLoginCache() async {
    Navigator.of(context).pushReplacementNamed('/domain');
  }

  @override
  void initState() {
    super.initState();

    new Timer(new Duration(seconds: _showSplashLengh), () {
      checkLoginCache();
    });
    
  }
}