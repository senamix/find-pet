import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scim/src/configs/base_config.dart';
import 'package:scim/src/login/views/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/models.dart';

//The AuthenticationRepository is responsible for abstracting
// the underlying implementation of how a user is authenticated, as well as how a user is fetched.
class AuthenticationRepository {

  Future<bool> logIn({String? username, String? password}) async {
    return await _generateToken(username!, password!);
  }

  void logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<Auth?> getAccountInfo() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final uri = Uri.parse(BaseConfig.devURL+"/account");
    final response = await http.get(uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      Auth auth = Auth.fromJson(map);
      return auth;
    }
    throw Exception('error get account');
  }

  //if login into app, then token is created because api server used jwt
  static Future<bool> _generateToken(String email, String password) async {
    Future<SharedPreferences> futurePrefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await futurePrefs;
    final uri = Uri.parse(BaseConfig.devURL + "/account/login");

    try {
      Auth account = Auth(email, password);
      final response = await http.post(uri,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8'
          },
            body: jsonEncode(account.toJson()));
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        Auth resAuth = Auth.fromJson(map);
        final token = resAuth.token;
        final username = resAuth.username;
        if (token != null && username != null) {
          await prefs.setString("token", token);
          await prefs.setString("username", username);
          return true;
        }
      }else if(response.statusCode == 400){
        return false;
      }
    } catch (e) {
      log('Authentication issue ' + e.toString());
    }
    return false;
  }

  static Future<bool> isRightToken(String? token) async {
    try {
      final uri = Uri.parse(BaseConfig.devURL + "/account");
      final response = await http.get(uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      log('Authentication issue ' + e.toString());
    }
    return false;
  }
}
