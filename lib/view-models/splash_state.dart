import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:outreach/api/login.dart';
import 'package:outreach/models/user.dart';
import 'package:outreach/views/splash_view.dart';
import 'package:outreach/util/cache_util.dart';

class Splash extends StatefulWidget {
  @override
  SplashView createState() => new SplashView();
}

abstract class SplashState extends State<Splash> with Login {
  int _splashScreenLengh = 1; // seconds
  final CacheUtil _cache = new CacheUtil();

  Future checkLoginCache() async {
    User user = await _cache.getCurrentUser();

    if(user == null){ // if we don't find a user
      Navigator.of(context).pushReplacementNamed('/domain');
    } else{ // if we do find a user
      try{
        // validate the api key
        await doKeyValidation(context, user).then((dynamic val){
          Navigator.of(context).pushReplacementNamed('/contacts');
        });
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
