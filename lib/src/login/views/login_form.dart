import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main/views/home_view.dart';
import '../bloc/login_bloc.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //get the screen size
    return BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status.isSubmissionFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('로그인 실패, 이메일과 비밀번호를 확인해주세요.')),);
          }
          if (state.status.isSubmissionSuccess) {
            Future.delayed(Duration.zero, () async {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeView()));
            });
          }
        },
        builder: (context, state){
          return Stack(
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/login.jpg"),
                      fit: BoxFit.cover,),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    child: Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).viewInsets.bottom == 0 ? size.height * 0.43 : 0),
                        alignment: Alignment.bottomCenter,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _UsernameInput(),
                              _PasswordInput(),
                              const Padding(padding: EdgeInsets.only(top: 10)),
                              _LoginButton(),
                              MediaQuery.of(context).viewInsets.bottom == 0
                                  ? Padding(padding: EdgeInsets.only(bottom: size.height * 0.08))
                                  : Container(),
                            ],
                          ),
                        )
                    )
                ),
              ]
          );
        }
    );
  }
}

class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) {
        return TextField(
          onChanged: (username) =>
              context.read<LoginBloc>().add(LoginUsernameChanged(username)),
          decoration: InputDecoration(
            hintText: '이메일',
            errorText: state.username.invalid ? '이메일은 필수 항목입니다.' : null,
            prefixIcon: const Icon(Icons.person, color: Colors.white,),
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          onChanged: (password) =>
              context.read<LoginBloc>().add(LoginPasswordChanged(password)),
          obscureText: true,
          decoration: InputDecoration(
            hintText: '비밀번호',
            errorText: state.password.invalid ? '비밀번호는 필수 항목입니다.' : null,
            prefixIcon: const Icon(Icons.password_sharp, color: Colors.white,),
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : Container(
            margin: const EdgeInsets.only(bottom: 0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    child: const Text('로그인', style: TextStyle(color: Colors.white),),
                    onPressed: state.status.isValidated
                        ? () {
                      context.read<LoginBloc>().add(const LoginSubmitted());
                    } : null,
                  ),
                ),
              ],
            ),
        );
      },
    );
  }
}
