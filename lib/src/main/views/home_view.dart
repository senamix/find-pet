import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scim/src/main/navigator/info_navigator.dart';

import '../navigator/info_navigator.dart';
import '../navigator/setting_navigator.dart';
import '../navigator/work_list_navigator.dart';

class HomeView extends StatefulWidget {
  HomeView({Key? key, this.flag}) : super(key: key);
  static const routeName = '/home';
  bool? flag;

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
  }

  List<BottomNavigationBarItem>? barItems(){
    return user1BarItems;
  }

  List<BottomNavigationBarItem> user1BarItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.menu),
      label: '메뉴',
    ),
    // const BottomNavigationBarItem(
    //   icon: Icon(Icons.location_on_rounded),
    //   label: '내 근처',
    // ),
    const BottomNavigationBarItem(
      icon: FaIcon(FontAwesomeIcons.home),
      label: '홈',
    ),
    const BottomNavigationBarItem(
      icon: FaIcon(FontAwesomeIcons.solidUser),
      label: '나의 정보',
    ),
  ];

  List<StatefulWidget>? navItems(){
    return userNavigator;
  }

  List<StatefulWidget> userNavigator = [
    const InfoNavigator(),
    const WorkListNavigator(),
    const SettingNavigator(),
  ];

  late int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        //top: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: navItems()!.map((value) => value).toList(),
        ),
      ),
      bottomNavigationBar:BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade500,
        unselectedItemColor: Colors.black54,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: barItems()!.map((value) => value).toList(),
      ),
    );
  }
}
