import 'dart:async';

import 'package:outreach/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// This class is used to store functions that are called
/// multiple times in our application. This a utility class. 
/// Most of the methods are related to caching and error handling.
class CacheUtil {
  // next three lines makes this class a Singleton
  static CacheUtil _instance = new CacheUtil.internal();
  CacheUtil.internal();
  factory CacheUtil() => _instance;

  /// cache instance
  Future<SharedPreferences> _sPrefs = SharedPreferences.getInstance();

  ///***************************************************************************
  ///                     C A C H E   M E T H O D S
  ///***************************************************************************

  /// This method to set a passed string value in cache
  /// under a passed string key.
  /// @param key - The key that is linked to a String value
  /// @param s - The string value
  /// @return A future object once the string and key
  /// have been set in the cache
  Future<Null> setString(String key, String s) async {
    final SharedPreferences prefs = await _sPrefs;
    prefs.setString(key, s);
  }

  /// This method gets the string of an object to remove
  /// @param key - The cache item to remove
  /// @return a future object to see if the value exists or not
  Future<Null> getString(String key) async {
    final SharedPreferences prefs = await _sPrefs;

    return prefs.getString(key) ?? "";
  }

  /// This method issued to clear a single value from cache
  /// @param key - The cache item to remove
  /// @return a future object once the item has been removed 
  Future<Null> removeCacheItem(String key) async {
    final SharedPreferences prefs = await _sPrefs;
    prefs.remove(key);
  }

  Future<Null> saveUser(User user) async {
    final SharedPreferences prefs = await _sPrefs;
    // the current users stored in cache
    List<String> users = await getUsers();
    String userAsJSON = user.toMap().toString();
    users.add(userAsJSON);
    prefs.setStringList("users", users);
  }

  Future<List<String>> getUsers() async {
    final SharedPreferences prefs = await _sPrefs;
    List<String> users = prefs.getStringList('users');

    return users;
  }

  Future<User> getCurrentUser() async {
    final SharedPreferences prefs = await _sPrefs;

    int currentUser = prefs.getInt('current_user');
    List<String> users = await getUsers();
    
    return new User.fromJSON(users[currentUser]);
  }

  Future<Null> setCurrentUser(int i) async {
    final SharedPreferences prefs = await _sPrefs;
    await prefs.setInt('current_user', i);
  }
}

