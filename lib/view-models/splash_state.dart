import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:outreach/api/auth.dart';
import 'package:outreach/models/user.dart';
import 'package:outreach/views/splash_view.dart';
import 'package:outreach/util/cache_util.dart';

class Splash extends StatefulWidget {
  @override
  SplashView createState() => new SplashView();
}

abstract class SplashState extends State<Splash> {
  int _splashScreenLengh = 1; // seconds
  final CacheUtil _cache = new CacheUtil();
  final ApiAuth _auth = new ApiAuth();

  Future checkLoginCache() async {
    User u = await _cache.getCurrentUser();

    if(u == null){
      Navigator.of(context).pushReplacementNamed('/domain');
    } else{
      try{
        await _auth.validateAPIKey(u.domain, u.apiKey, u.apiExpiry);
        Navigator.of(context).pushReplacementNamed('/contacts');
      } on Exception catch(e) {
        print(e.toString());
        // clear the cache of outdated api key
        // push to login
      }
    }
  }

  @override
  void initState() {
    super.initState();

    new Timer(new Duration(seconds: _splashScreenLengh), () {
      checkLoginCache();
    });
    
  }
}