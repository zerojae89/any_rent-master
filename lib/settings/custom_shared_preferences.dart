import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// shared_preferences 클래스화 한다
class CustomSharedPreferences {


  Future<dynamic> getBool(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool result = (prefs.getBool(key) ?? false );
    return result;
  }

  Future<dynamic> getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String result = (prefs.getString(key) ?? null );
    return result;
  }

  Future<void> remove(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
  
  Future<void> setString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }
}

CustomSharedPreferences  customSharedPreferences = CustomSharedPreferences();