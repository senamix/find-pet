import 'package:scim/src/worker/views/work_list_view.dart';
import 'package:flutter/material.dart';

class WorkListNavigator extends StatefulWidget {
  const WorkListNavigator({Key? key}) : super(key: key);

  @override
  _WorkListNavigatorState createState() => _WorkListNavigatorState();
}

class _WorkListNavigatorState extends State<WorkListNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
            settings: settings,
            builder: (BuildContext context) {
              switch (settings.name) {
                // case '/detail':
                //   return WorkListDetailView();
                case '/':
                  return WorkListView();
                default:
                  return WorkListView();
              }
        });
      },
    );
  }
}
