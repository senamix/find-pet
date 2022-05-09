import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scim/splash/view/splash_page.dart';
import 'package:scim/src/auth/authentication_repository.dart';
import 'package:scim/src/common/dialog_widget.dart';
import 'package:scim/src/setting/views/userid.dart';
import 'package:scim/src/setting/views/username.dart';

import '../../login/models/models.dart';
import '../../login/views/login_page.dart';
import '../bloc/setting_bloc.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final SettingBloc _settingBloc = SettingBloc();

  @override
  void initState() {
    super.initState();
    _settingBloc.add(const SettingGetUser());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingBloc, SettingState>(
        listener: (context, state){
          if(state.status == SettingStatus.failure){
            DialogWidget.flutterSnackBar(context,content: "API 반환 오류");
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case SettingStatus.success:
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(padding: EdgeInsets.only(bottom: 10)),
                    _renderUserAvatarAndBio(),
                    const Padding(padding: EdgeInsets.only(bottom: 30)),
                    _renderItem(context,Icons.line_weight_sharp, "나의 글", 1, state),
                    _renderItem(context,Icons.workspaces_filled, "아이디", 2, state),
                    _renderItem(context,Icons.drive_file_rename_outline, "사용자 이름", 3, state),
                    _renderItem(context,Icons.logout, "로그아웃", 4, state)
                  ],
                ),
              );
            default:
              return const SplashPage();
          }
        }
    );
  }

  Row _renderUserAvatarAndBio(){
    return Row(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/login.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 15, right: 15)),
            const Text("Hello everyone!!!"),
          ],
        ),
      ],
    );
  }

  InkWell _renderItem(BuildContext context, IconData icon, String text, int index, SettingState state){
    return InkWell(
      child: Row(
        children: [
          Row(
            children: [
              Icon(icon, size: 30,),
              const Padding(padding: EdgeInsets.only(left: 20)),
              Text(text,style: const TextStyle(fontSize: 20),),
            ],
          ),
          const Padding(padding: EdgeInsets.only(bottom: 50)),
        ],
      ),
      onTap: (){
        _redirectToDestinationScreenByIndex(index, state);
      },
    );
  }

  _redirectToDestinationScreenByIndex(int index, SettingState state){
    if(index == 2){
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => UserIdView(auth: state.auth,)));
    }else if(index == 3){
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => UsernameView(auth: state.auth,)));
    }else if(index == 4){
      AuthenticationRepository authenticationRepository = AuthenticationRepository();
      authenticationRepository.logOut();
      //Flutter how to remove bottom navigation with navigation
      //https://stackoverflow.com/questions/52322340/flutter-how-to-remove-bottom-navigation-with-navigation
      Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }
}