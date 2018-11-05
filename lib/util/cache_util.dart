import 'dart:async';
import 'dart:convert';

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
    print("\nSAVING CURRENT USER {"
      "\n\tname: ${user.name}"
      "\n\tusername: ${user.username}"
      "\n\tdomain: ${user.domain}"
      "\n\texpiry: ${user.apiExpiry}"
      "\n\tkey: ${user.apiKey}"
      "\n}"
    );

    // get the current users stored in cache
    List<String> users = await getUsers();
    if(users == null) users = new List();

    // map our user object to a JSON string and add it to users
    String userAsJSON = json.encode(user.toMap());

    // if our list doesn't already contain us
    if(!users.contains(userAsJSON)){
      users.add(userAsJSON);
    }

    print("USER LIST: $users");

    // set the current logged in user to the index of it in cache
    setCurrentUser(users.indexOf(userAsJSON));

    // overwrite the list of users with the new user appended
    prefs.setStringList("users", users);
  }

  Future<List<String>> getUsers() async {
    final SharedPreferences prefs = await _sPrefs;

    // get and return the list of user JSON objects
    List<String> users = prefs.getStringList('users');
    return users;
  }

  Future<User> getCurrentUser() async {
    final SharedPreferences prefs = await _sPrefs;
    print("RETREIVING CURRENT USER {");

    // get the index of the current user
    int currentUser = prefs.getInt('current_user');
    // get the list of users from cache
    List<String> users = await getUsers();
    if(users != null) {
      var data = json.decode(users[currentUser]);
      User user = new User.fromJSON(data);
      print(
        "\tname: ${user.name}"
        "\n\tusername: ${user.username}"
        "\n\tdomain: ${user.domain}"
        "\n\texpiry: ${user.apiExpiry}"
        "\n\tkey: ${user.apiKey}"
        "\n}"
      );
      return user;
    } else {
      print("\tdata: no user found:\n}");
      return null;
    }
  }


  /// lets say for example we have a list view of
  /// all the different accounts you can log into.
  /// we simply grab the index of the list item 
  /// the user clicked on, and set the current user 
  /// to that index.
  /// then -> when we go to get the current user object,
  /// it will be the one stored under that index! 
  Future<Null> setCurrentUser(int i) async {
    final SharedPreferences prefs = await _sPrefs;
    await prefs.setInt('current_user', i);
  }

  Future<Null> clearAllUsers() async {
    final SharedPreferences prefs = await _sPrefs;
    await prefs.setStringList('users', null);
  }
}

