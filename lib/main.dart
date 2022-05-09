import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scim/src/auth/authentication_repository.dart';
import 'package:scim/src/common/simple_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences : https://pub.dev/packages/shared_preferences
  // fix cannot await SharedPreferences in flutter: https://github.com/flutter/flutter/issues/94932
  Future<SharedPreferences> futurePrefs = SharedPreferences.getInstance();
  SharedPreferences prefs = await futurePrefs;

  //get token before display screen
  String? token =  prefs.getString("token");

  bool isLogin = await AuthenticationRepository.isRightToken(token);
  if(isLogin == true){
    prefs.setString("isLogin", '1');
  }

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  //runApp(MyApp());
  BlocOverrides.runZoned(
        () => runApp(const MyApp()),
    blocObserver: SimpleBlocObserver(),
  );
}