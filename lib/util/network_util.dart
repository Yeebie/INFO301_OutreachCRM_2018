import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkUtil {
  // next three lines makes this class a Singleton
  static NetworkUtil _instance = new NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;

  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> get(String url, bool auth) {
    return http.get(url).then((http.Response response) {
      final String result = response.body;
      final int statusCode = response.statusCode;

      if(statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("$statusCode error while fetching data");
      }

      if(!auth) return _decoder.convert(result);
      return result;
    });
  }

  Future<dynamic> post(String url, {Map headers, body, encoding}) {
    return http
      .post(url, body: body, headers: headers, encoding: encoding)
      .then((http.Response response) {
        final String result = response.body;
        final int statusCode = response.statusCode;
        if(statusCode < 200 || statusCode > 400 || json == null) {
          throw new Exception("Error while fetching data");
        }
        return _decoder.convert(result);
      });
  }


}