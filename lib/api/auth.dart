
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:outreach/util.dart';

///Used to utilise REST operations
import 'package:http/http.dart' as http;

class ApiAuth {


  /// Method used for validating that the domain exists.
  /// Uses a simple 404 error check
  ///
  /// @param domain - the user entered domain to validate
  static Future<bool> getDomainValidation(String domain, BuildContext context) async {
    bool _isDomain = false;
    //Creating the URL that'll query the database for our API Key
    String _requestDomainValidation = "https://" + domain + ".outreach.co.nz";
    print('Creating the URL to check if current Domain is valid: ' +
        _requestDomainValidation);

    var wifiEnabled = await Util.getWifiStatus();
    if (wifiEnabled) {
      await http.get(_requestDomainValidation).then((response) {
        //Print the API Key, just so we can compare it to the final result
        print("Original Response body: ${response.statusCode}");

        print("Checking if domain is valid");
        if (response.statusCode.toString() == "404") {
          print(domain + " is not a valid domain");
          _isDomain = false;
        } else {
          print(domain + " is a valid domain");
          _isDomain = true;
        }
        print("Printing _isDomain");
        print(_isDomain);
        print("Domain is valid, sending to LoginPage");
        print("\n\n");

        if (_isDomain == false) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text("Domain does not exist"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Okay"),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ],
                  ));
        } else {
          // push to login page my guy
        }
      });
    } else {
      _showDialogParent("No Internet Connection",
          "Please connect to the internet to use this application.", context);
    }
    return _isDomain;
  }

  /// Wrapper method for UI
  /// Used for error messages.
  /// On ok button press the app exits.
  ///
  /// @param title - The title of the error message
  /// @param content - The content of the dialog box
  static void _showDialogParent(String title, String content, BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(title),
              content: new Text(content),
              actions: [
                new FlatButton(
                  child: const Text("Ok"),
                  onPressed: () => exit(0),
                ),
              ],
            ));
  }
}