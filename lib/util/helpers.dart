import 'package:flutter/material.dart';
import 'package:outreach/api/auth.dart';
import 'package:outreach/models/user.dart';
import 'package:outreach/util/cache_util.dart';

class Util {
  static hideSoftKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  static showSnackBar(String text, GlobalKey<ScaffoldState> scaffoldKey,
                      bool isErrorMessage) {
    scaffoldKey.currentState
      .showSnackBar(
        new SnackBar(
          content: 
            new Text(
              text,
              style: new TextStyle(
                color: isErrorMessage
                ? Colors.red
                : Colors.white   
              ),
            ),
          duration:
            new Duration(seconds: 2),
        )
      );
  }

  /// Shows dialog box based on params passed.
  /// Returns a future so we can perform actions when closed.
  ///
  /// @param title - The title of the error message
  /// @param content - The content of the dialog box
  /// @param showCancel - set this to true if you want it cancelable
  static Future<bool> showDialogParent(String title, String content,
        BuildContext context, bool showCancel) async {

    // if the user accepts the dialog
    bool accepted = false;

    return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => new AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
            showCancel 
            ?
            new FlatButton(
              child: const Text("cancel"),
              onPressed: (() {
                Navigator.of(context).pop();
                return accepted = false;
              }))
            : 
            null, 

            new FlatButton(
              child: const Text("OK"),
              onPressed: (() {
                Navigator.of(context).pop();
                return accepted = true;
              })
            ),
          ],
        )).then((dynamic val) {
          return accepted;
        });
  }

  static logout(BuildContext context) async {
    CacheUtil _cache = new CacheUtil();
    ApiAuth _auth = new ApiAuth();

    User user = await _cache.getCurrentUser(); 
    bool loggedOut = await _auth.destroyAPIKey(user);

    if(loggedOut){
      await _cache.clearAllUsers();

      // push to the home page and remove everything from stack
      Navigator.of(context).pushNamedAndRemoveUntil('/',
              (Route<dynamic> route) => false);
    }
    // TODO: Write a method to clear only current user
    // clear all users for now, later we will remove just current    
  }
}