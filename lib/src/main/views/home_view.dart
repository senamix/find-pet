import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scim/src/main/navigator/info_navigator.dart';
import 'package:scim/src/worker/views/work_around.dart';

import '../navigator/info_navigator.dart';
import '../navigator/setting_navigator.dart';
import '../navigator/work_list_navigator.dart';

class HomeView extends StatefulWidget {
  HomeView({Key? key, this.flag, this.initIndex}) : super(key: key);
  static const routeName = '/home';
  bool? flag;
  int? initIndex;

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late int _selectedIndex;

  @override
  void initState() {
    _selectedIndex = widget.initIndex ?? 1;
    super.initState();
  }

 List<BottomNavigationBarItem> user1BarItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.menu),
      label: '메뉴',
    ),
    const BottomNavigationBarItem(
      icon: FaIcon(FontAwesomeIcons.home),
      label: '홈',
    ),
    const BottomNavigationBarItem(
      icon: FaIcon(Icons.flag),
      label: '나의 근처',
    ),
    const BottomNavigationBarItem(
      icon: FaIcon(FontAwesomeIcons.solidUser),
      label: '나의 정보',
    ),
  ];

  List<StatefulWidget> userNavigator = [
    const InfoNavigator(),
    const WorkListNavigator(),
    WorkerAround(),
    const SettingNavigator(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        //top: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: userNavigator.map((value) => value).toList(),
        ),
      ),
      bottomNavigationBar:BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade500,
        unselectedItemColor: Colors.black54,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
            if(index == 2){
              Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 0),
                      transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                      pageBuilder: (c, a1, a2) => HomeView(initIndex: 2,)
                  )
              );
            }
          });

        },
        items: user1BarItems.map((value) => value).toList(),
      ),
    );
  }
}
