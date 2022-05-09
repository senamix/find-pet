import 'package:equatable/equatable.dart';

class Auth extends Equatable{
  String? username;
  String? email;
  String? password;
  String? token;
  String? displayName;
  String? image;

  Auth(this.email,this.password);

  Auth.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        email = json['email'],
        displayName = json['displayName'],
        image = json['image'],
        token = json['token'];

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password
  };

  @override
  List<Object> get props => [username!, displayName!];
}