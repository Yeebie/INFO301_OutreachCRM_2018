import 'package:flutter/cupertino.dart';
import 'package:outreach/util/network_util.dart';
import 'package:outreach/models/user.dart';
import 'package:outreach/api/auth.dart';
import 'package:outreach/util/helpers.dart';

class Login {
  NetworkUtil _netUtil = new NetworkUtil();
  final ApiAuth _auth = new ApiAuth();
  String baseURL;

  Future<User> doLogin(String domain, String username, String password) {
    baseURL = "https://$domain.outreach.co.nz/api/0.2";
    String loginURL = baseURL + "/auth/login/";

    return _netUtil.post(loginURL, body: {
      "username": username,
      "password": password,
      "expiry": "12 months"
    }).then((dynamic result) {
      if (result["error"] != null) {
        throw new LoginException(error: result["error"].toString());
      }
      return new User.map(result["data"], username, domain);
    });
  }

  Future getFullName(User user) {
    var url = "$baseURL/query/user";
    var properties = "['name_processed']";
    var conditions = "[['login','=','${user.username}']]";

    return _netUtil.post(url, body: {
      "apikey": user.apiKey,
      "properties": properties,
      "conditions": conditions
    }).then((dynamic result) {
      user.updateNameFromJSON(result);
      return null;
    });
  }

  /// method to take a user object and validate the api key,
  /// if the key does not validate, catch the exception, show
  /// a dialog, then log us out
  Future doKeyValidation(BuildContext context, User user) async {
    // try validate api key
    // TODO: move this to _auth
    try {
      await _auth.validateAPIKey(
        user.domain,
        user.apiKey,
        user.apiExpiry
      );
    } on Exception catch (e) {
      // force logout on invalid key
      print(e.toString());
      Util.showDialogParent(
              "Logged out",
              "We logged you out because your API key was old, soz lol",
              context)
      .then((Null ignore) {
        // do this after we close it
        Util.logout(context);
      });
    }
    return null;
  }
}

class LoginException implements Exception {
  String error;

  LoginException({@required this.error});

  String errorMessage() {
    return error;
  }
}
