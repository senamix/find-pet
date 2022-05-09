import 'package:flutter/material.dart';

import '../../setting/views/setting_page.dart';

class SettingNavigator extends StatefulWidget {
  const SettingNavigator({Key? key}) : super(key: key);

  @override
  _SettingNavigatorState createState() => _SettingNavigatorState();
}

class _SettingNavigatorState extends State<SettingNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            switch(settings.name) {
              case '/':
              default:
                return const SettingPage();
            }
          }
        );
      },
    );
  }
}
