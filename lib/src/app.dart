import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:scim/src/main/views/home_view.dart';
import 'package:scim/src/setting/views/setting_page.dart';
import 'package:scim/src/worker/views/views.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login/views/login_page.dart';
import 'main/views/info_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<String?> get jwtOrEmpty async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<String?> get isLogin async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("isLogin");
  }

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return MaterialApp(
      // Providing a restorationScopeId allows the Navigator built by the
      // MaterialApp to restore the navigation stack when a user leaves and
      // returns to the app after it has been killed while running in the
      // background.
      restorationScopeId: 'app',

      // Provide the generated AppLocalizations to the MaterialApp. This
      // allows descendant Widgets to display the correct translations
      // depending on the user's locale.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('ko', 'KR'), // Korean
      ],

      locale: const Locale('ko'),

      // Use AppLocalizations to configure the correct application title
      // depending on the user's locale.
      //
      // The appTitle is defined in .arb files found in the localization
      // directory.
      onGenerateTitle: (BuildContext context) =>
      AppLocalizations.of(context)!.appTitle,

      // Define a light and dark color theme. Then, read the user's
      // preferred ThemeMode (light, dark, or system default) from the
      // SettingsController to display the correct theme.
      theme: ThemeData(
        //fontFamily: 'NanumBarunGothicLight',
      ),
      darkTheme: ThemeData.light(),
      themeMode: ThemeMode.system,

      // initial route
      //initialRoute: "/login",
      home: FutureBuilder(
          future: isLogin,
          builder: (context, snapshot) {
            if(!snapshot.hasData) return const LoginPage();
            if(snapshot.data != null) {
              if(!snapshot.hasData) return const LoginPage();
              if(snapshot.data != null) {
                return HomeView();
              }
              return const Center(child: CircularProgressIndicator());
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(),),
            );
          }
        ),

      // Define a function to handle named routes in order to support
      // Flutter web url navigation and deep linking.
      onGenerateRoute: (RouteSettings routeSettings) {
        developer.log("Router Name : ${routeSettings.name}", name: "route");

        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case HomeView.routeName:
                return HomeView();
              case SettingPage.routeName:
                return const SettingPage();
              case InfoView.routeName:
                return const InfoView();
              case WorkListView.routeName:
                return WorkListView();
              case LoginPage.routeName: //login route
                return const LoginPage();
              default:
                developer.log("Default route to ...");
                return const LoginPage();
            }
          },
        );
      },
    );
  }
}
