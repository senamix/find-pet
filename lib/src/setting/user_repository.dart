import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:scim/src/auth/authentication_repository.dart';
import 'package:scim/src/configs/base_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/models.dart';

class UserRepository {
  String requestApi = BaseConfig.baseUrl+"/users";

  Future<User?> getUserById() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      String? userId = prefs.getString("userId");
      final uri = Uri.parse(requestApi+"?userId=$userId");
      final response = await http.get(uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        Iterable body = json.decode(response.body);
        List<User> users = List<User>.from(body.map((user) => User.fromJson(user)));
        User user = users[0];
        String jsonUser = jsonEncode(user);
        prefs.setString("user", jsonUser);
        String? cmoId = user.cmo?.id;
        if(cmoId != null){
          prefs.setString("cmoId", cmoId);
        }
        return user;
      }
      throw Exception('error getting user by token');
  }

  Future<User?> changeUploadModeRequest(bool uploadedPic) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final uri = Uri.parse(requestApi+"/uploaded_pic");
    Map<String, dynamic> jsonUploadedPic() => {
      'uploadedPic': uploadedPic
    };
    final response = await http.post(uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"},
          body: jsonEncode(jsonUploadedPic()),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      User user = User.fromJsonOption(map);
      bool? uploadedPic = user.uploadedPic;
      prefs.setBool("uploadedPic", uploadedPic!);
      return user;
    }
    throw Exception('error putting uploaded_pic mode');
  }
}
