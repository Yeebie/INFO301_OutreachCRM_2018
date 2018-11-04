import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outreach/api/auth.dart';
import 'package:outreach/util/helpers.dart';
import 'package:outreach/view-models/contacts_state.dart';
import 'package:outreach/views/login_view.dart';
import 'package:outreach/api/login.dart';
import 'package:outreach/models/user.dart';

class LoginPage extends StatefulWidget {
  final String domain;
  LoginPage(this.domain);

  @override
  LoginView createState() => new LoginView();
}

abstract class LoginState extends State<LoginPage> with Login{
  @protected
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final List<String> formFields = new List(2);
  bool attemptingLogin = false;
  User user;
  final ApiAuth auth = new ApiAuth();


  @protected
  submit() async {
    final form = formKey.currentState;
    if(form.validate()){
      form.save();

      String _domain = widget.domain;
      String _username = formFields[0];
      String _password = formFields[1];

      setState(() => attemptingLogin = true);

      try {
        // do the login, assign result to new user
        user = await doLogin(_domain, _username, _password);

        // validate the key
        await doKeyValidation(context, user);

        // attempt to grab full name of user
        await getFullName(user);

        // cache user as JSON

        // show who we are logged in as
        Util.showSnackBar(
          "Welcome ${user.name}!",
          scaffoldKey,
          false
        );

        // wait for snack bar to disappear then push to contacts page
        await new Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => new Contacts(user))
        );

      } on LoginException catch(e){ // error our API request throws
        // show a snackbar with error message
        // e.g. "invalid username or password"
        Util.showSnackBar(
          e.errorMessage(),
          scaffoldKey,
          true
        );

        // wait for snack bar to disappear then hide loading modal
        await new Future.delayed(const Duration(seconds: 2));
        setState(() => attemptingLogin = false);
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