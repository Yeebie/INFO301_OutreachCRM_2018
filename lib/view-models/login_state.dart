import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreach/views/login_view.dart';
// import 'package:outreach/api/auth.dart';
import 'package:outreach/api/login.dart';
import 'package:outreach/models/user.dart';

class LoginPage extends StatefulWidget {
  final String domain;
  LoginPage(this.domain);

  @override
  LoginPageView createState() => new LoginPageView();
}

abstract class LoginPageState extends State<LoginPage> with Login{
  @protected
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final List<String> formFields = new List(2);
  bool loginSuccess = false;
  User user;

  @protected
  void _showSnackBar(String text) {
    scaffoldKey.currentState
      .showSnackBar(
        new SnackBar(
          content: new Text(text),
          duration: new Duration(seconds: 2),
        )
      );
  }


  @protected
  submit() async {
    final form = formKey.currentState;
    if(form.validate()){
      form.save();

      String _domain = widget.domain;
      String _username = formFields[0];
      String _password = formFields[1];

      print(_domain + " " + _username + " " + _password);

      setState((){
        loginSuccess = true;
      });

      try {
        user = await login(_domain, _username, _password);
        if(user != null){
          print("USER: ${user.username}");
          _showSnackBar("Logged in as ${user.username}");
          // cache user as JSON
        }
      } on LoginException catch(e){
        print(e.errorMessage());
        _showSnackBar(e.errorMessage());
        await new Future.delayed(const Duration(seconds: 2));
        setState(() => loginSuccess = false);
      }
    }

    // user.apiExpiry.isAfter(DateTime.now()) ? print("ITS AFTER") : print("BEFORE BITCH");

  }


  @protected
  String validateUserName(String value) {
    RegExp userNamePattern = new RegExp(
      r"^[a-zA-Z0-9@.]*$",
      caseSensitive: false,
      multiLine: false,
    );
    if (userNamePattern.hasMatch(value)) {
      if (value == "") {
        return "Please enter a username";
      } else if (value.length > 255) {
        return "Your username is too long";
      }
    } else {
      return 'Invalid characters in username';
    }
    return null;
  }

  @protected
  String validatePassword(String value) {
    RegExp passwordPattern = new RegExp(
      r"^[a-zA-Z0-9]*$",
      caseSensitive: false,
      multiLine: false,
    );
    if (passwordPattern.hasMatch(value)) {
      if (value == "") {
        return "Please enter a password";
      } else if (value.length < 6) {
        return "Password must be at least 6 characters";
      } else if (value.length > 255) {
        return "Your password is too long";
      }
    } else {
      return 'Invalid characters in password';
    }
    return null;
  }
}