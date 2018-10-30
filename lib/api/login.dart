import 'package:flutter/cupertino.dart';
import 'package:outreach/util/network_util.dart';
import 'package:outreach/models/user.dart';

class Login {
  NetworkUtil _netUtil = new NetworkUtil();
  static String baseURL;

  Future<User> login(String domain, String username, String password) {
    baseURL = "https://" + domain +
        ".outreach.co.nz/api/0.2";
    String loginURL = baseURL + "/auth/login/";

    return _netUtil.post(loginURL, body: {
      "username": username,
      "password": password
    }).then((dynamic result) {
      print(result.toString());
      if(result["error"] != null) {
        throw new LoginException(error: result["error"].toString());
      }
      return new User.map(result["data"], username, domain);
    });
  }
}

class LoginException implements Exception {
  String error;

  LoginException({
    @required this.error
  });

  String errorMessage(){
    return error;
  }
}