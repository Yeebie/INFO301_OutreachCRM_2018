import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:outreach/view-models/splash_state.dart';

class SplashView extends SplashState {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new ModalProgressHUD(
        inAsyncCall: true,
        child: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/images/background-image.png'),
              fit: BoxFit.cover,
            ),
          ),
        )
      )
    );
  }
  
}
