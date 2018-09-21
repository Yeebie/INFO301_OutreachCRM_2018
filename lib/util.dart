import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class Util {
  /// data fields
  static Future<SharedPreferences> _sPrefs = SharedPreferences.getInstance();



  ///***************************************************************************
  ///                     C A C H E   M E T H O D S
  ///***************************************************************************

  /// method to set a passed string value in cache under a passed string key.
  static Future<Null> setString(String key, String s) async {
    final SharedPreferences prefs = await _sPrefs;
    prefs.setString(key, s);
  }

  /// cannot get working in helper class, use in class for now
  static Future<Null> getString(String key) async {
    final SharedPreferences prefs = await _sPrefs;

    return prefs.getString(key) ?? "";
  }


  /// method used to clear a single value from cache
  static Future<Null> removeCacheItem(String key) async {
    final SharedPreferences prefs = await _sPrefs;
    prefs.remove(key);
  }


}