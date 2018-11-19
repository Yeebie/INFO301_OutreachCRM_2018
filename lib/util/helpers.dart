import 'package:flutter/material.dart';
import 'package:outreach/util/cache_util.dart';

class Util {
  static hideSoftKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  static showSnackBar(String text, GlobalKey<ScaffoldState> scaffoldKey
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
  static Future<Null> showDialogParent(String title, String content,
        BuildContext context) {

    return showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (_) => new AlertDialog(
              title: new Text(title),
              content: new Text(content),
              actions: <Widget>[
                new FlatButton(
                  child: const Text("OK"),
                  onPressed: () => Navigator.of(context).pop()
                ),
              ],
            ));
  }

  static logout(BuildContext context){
    CacheUtil _cache = new CacheUtil();
    // TODO: Write a method to clear only current user
    // clear all users for now, later we will remove just current
    _cache.clearAllUsers();

    // push to the home page and remove everything from stack
    Navigator.of(context).pushNamedAndRemoveUntil('/',
              (Route<dynamic> route) => false);
  }
}