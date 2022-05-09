import 'package:scim/src/main/views/info_view.dart';
import 'package:flutter/material.dart';

class InfoNavigator extends StatefulWidget {
  const InfoNavigator({Key? key}) : super(key: key);

  @override
  _InfoNavigatorState createState() => _InfoNavigatorState();
}

class _InfoNavigatorState extends State<InfoNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(onGenerateRoute: (RouteSettings settings) {
      return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            switch (settings.name) {
              case '/':
              default:
                return const InfoView();
            }
          });
    });
  }
}
