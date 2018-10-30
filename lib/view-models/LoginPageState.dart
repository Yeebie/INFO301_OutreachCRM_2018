import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreach/views/LoginPageView.dart';
import 'package:outreach/api/auth.dart';

class LoginPage extends StatefulWidget {
  final String domain;
  LoginPage(this.domain);

  @override
  LoginPageView createState() => new LoginPageView();
}

abstract class LoginPageState extends State<LoginPage> {
  @protected
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final List<String> formFields = new List(2);
  // true to show the login page, false to show the domain
  bool loginOrDomain = false;
  bool domainSuccess = false;
  bool loginSuccess = false;


  @protected
  submit(BuildContext context) async {
    final form = formKey.currentState;
    if(form.validate()){
      form.save();

      String _domain = widget.domain;
      String _username = formFields[0];
      String _password = formFields[1];

      setState((){
        domainSuccess = true;
      });

      var domainStatus = 
        await ApiAuth.getDomainValidation(_domain, context);

      if(!domainStatus){
        setState((){
          domainSuccess = false;
        });
      }
    }
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