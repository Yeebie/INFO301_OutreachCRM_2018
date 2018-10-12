import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';


/// This class is used to store functions that are called
/// multiple times in our application. This a utility class. 
/// Most of the methods are related to caching and error handling.
class Util {
  /// data fields
  static Future<SharedPreferences> _sPrefs = SharedPreferences.getInstance();

  ///***************************************************************************
  ///                     C A C H E   M E T H O D S
  ///***************************************************************************

  /// This method to set a passed string value in cache
  /// under a passed string key.
  /// @param key - The key that is linked to a String value
  /// @param s - The string value
  /// @return A future object once the string and key
  /// have been set in the cache
  static Future<Null> setString(String key, String s) async {
    final SharedPreferences prefs = await _sPrefs;
    prefs.setString(key, s);
  }

  /// This method gets the string of an object to remove
  /// @param key - The cache item to remove
  /// @return a future object to see if the value exists or not
  static Future<Null> getString(String key) async {
    final SharedPreferences prefs = await _sPrefs;

    return prefs.getString(key) ?? "";
  }

  /// This method isused to clear a single value from cache
  /// @param key - The cache item to remove
  /// @return a future object once the item has been removed 
  static Future<Null> removeCacheItem(String key) async {
    final SharedPreferences prefs = await _sPrefs;
    prefs.remove(key);
  }

  ///***************************************************************************
  ///                     E R R O R   C H E C K I N G
  ///***************************************************************************

  /// Determines if the user has an internet
  /// connection. Pings google to check.
  /// @return True if the user has internet, 
  /// false otherwise
  static Future<bool> getWifiStatus() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }
}
