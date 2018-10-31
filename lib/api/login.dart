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
      "password": password,
      "expiry": "12 months"
    }).then((dynamic result) {
      print(result.toString());
      if(result["error"] != null) {
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
      var list = result['data'] as List;
      print(list[0].toString());
      print(result.toString());
      
      return null;
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