import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:async/async.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as path;
import 'package:scim/src/auth/authentication_repository.dart';
import 'package:scim/src/configs/base_config.dart';
import 'package:scim/src/setting/models/models.dart';
import 'package:scim/src/utils/convert_date.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/models/auth.dart';
import 'models/models.dart';

class WorkerRepository {
  AuthenticationRepository authenticationRepository = AuthenticationRepository();

  Future<List<Post>?> getListPost([int page = 1]) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    Auth? auth = await authenticationRepository.getAccountInfo();
    if(auth != null){
      final uri = Uri.parse(BaseConfig.devURL+"/posts");
      final response = await http.get(uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"}
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        Iterable body = json.decode(response.body);
        List<Post> posts = List<Post>.from(body.map((post) => Post.fromJson(post)));
        return posts;
      }
    }

    throw Exception('error getting list doing plan by token');
  }

  Future<bool>? followPost(String postId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final uri = Uri.parse(BaseConfig.devURL+'/posts/$postId/follow');
    final response = await http.post(uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
    );

    if (response.statusCode >= 200 && response.statusCode <= 304) {
      return true;
    }

    throw Exception('error posting plan err');
  }

  Future<bool>? getFollowPost(String postId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    Auth? auth = await authenticationRepository.getAccountInfo();
    final uri = Uri.parse(BaseConfig.devURL+'/posts/$postId');
    final response = await http.get(uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
    );

    if (response.statusCode >= 200 && response.statusCode <= 304) {
      Map<String, dynamic> map = jsonDecode(response.body);
      Post? post = Post.fromJson(map);
      if(auth != null && post.postParticipants != null){
        if(post.postParticipants!.contains(auth)){
          return true;
        }else{
          return false;
        }
      }
    }

    throw Exception('error posting plan err');
  }

  Future<int>? getFollowPostCount(String postId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    Auth? auth = await authenticationRepository.getAccountInfo();
    final uri = Uri.parse(BaseConfig.devURL+'/posts/$postId');
    final response = await http.get(uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
    );

    if (response.statusCode >= 200 && response.statusCode <= 304) {
      Map<String, dynamic> map = jsonDecode(response.body);
      Post? post = Post.fromJson(map);
      if(auth != null && post.postParticipants != null){
        return post.postParticipants?.length ?? 0;
      }
    }
    throw Exception('error posting plan err');
  }

  Future<List<Tag>>? getAllTags() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final uri = Uri.parse(BaseConfig.devURL+'/tags');
    final response = await http.get(uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
    );

    if (response.statusCode >= 200 && response.statusCode <= 304) {
      Iterable body = json.decode(response.body);
      List<Tag> tags = List<Tag>.from(body.map((tag) => Tag.fromJson(tag)));
      return tags;
    }
    throw Exception('error posting plan err');
  }

  static Future<List<String>>? getRoadInfo(String address) async{
    String vworld = 'http://api.vworld.kr/req/search?service=search&request=search&version=2.0&size=20&page=1&query=가산&type=address&format=json&errorformat=json&key=7DE98C24-F447-3263-BD86-A3AB1E460311&category=road';

    final uri = Uri.parse(vworld);
    final response = await http.get(uri,
      headers: {
        "Content-Type": "application/json",
      }
    );

    if (response.statusCode >= 200 && response.statusCode <= 304) {
      Map<String, dynamic> map = jsonDecode(response.body);
      Map<String, dynamic> res = map["response"];
      Map<String, dynamic> result = res["result"];
      List<dynamic> items = result["items"];
      List<dynamic> addresses = [];
      for (var element in items) {
        addresses.add(element["address"]);
      }
      List<String> roads = [];
      for (var element in addresses) {
        roads.add(element["road"]);
      }
      return roads;
    }
    throw Exception('error posting plan err');
  }





  Future<Post?> createdNewPlan(String cvplTyId, String name) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    Position _currentPosition = await _determinePosition();
    Auth? auth = await AuthenticationRepository().getAccountInfo();

    Map<String, dynamic> map() => cvplTyId == "5cfda3bab615b60845c79dda" ? {
      'cvplTy': cvplTyId,
      'cvplCn' : '$name 작업추가',
      'lineNum' : '0',
      'directionUpDn' : false, //상행
    } : {
      'cvplTy': cvplTyId,
      'cvplCn' : '$name 작업추가',
    };

    final uri = Uri.parse(BaseConfig.baseUrl+'/cvpls/worker');
    final response = await http.post(uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
        body: jsonEncode(map()),
    );

    if (response.statusCode >= 200 && response.statusCode <= 304) {
      Map<String, dynamic> map = jsonDecode(response.body);
      Post plan = Post.fromJson(map);
      return plan;
    }

    throw Exception('error posting plan err');
  }

  //to get address text and point from vworld
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('작업사진의 정확한 위치를 위해 위치정보 권한이 필요합니다.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('작업사진의 정확한 위치를 위해 위치정보 권한이 필요합니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        //desiredAccuracy: LocationAccuracy.bestForNavigation,
      // forceAndroidLocationManager: true,
      // timeLimit: null,
    );
  }

  Future<List<Photo>?> getListPhotoPlan(String postId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final uri = Uri.parse(BaseConfig.devURL+"/posts/$postId");
    final response = await http.get(uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"});
    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> map = jsonDecode(response.body);
      Post post = Post.fromJson(map);
      return post.photos;
    }

    throw Exception('error getting list doing plan by token');
  }

  Future<bool?> changePlanStatus(String planId, String statusLevel) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    Map<String, dynamic> map = {
      'opertSttus': statusLevel,
    };
    final uri = Uri.parse(BaseConfig.baseUrl+"/plans/$planId");
    final response = await http.put(uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"},
        body: jsonEncode(map));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }
    throw Exception('error putting a plan by token');
  }

  Future<bool?> savePlanPhoto(String imagePath, bool before, String planId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    bool? uploadPic = prefs.getBool("uploadedPic");

    //get path info of file
    String dir = path.dirname(imagePath);
    String newPath = path.join(dir, '${planId}_${ConvertDate.formatStringByPattern('yyyyMMddHHmmssSSS',DateTime.now())}.jpg');
    File image = File(imagePath);

    //change name of image, after save the image to disk
    //Both images and videos will be visible in Android Gallery and iOS Photos.
    File file = image.renameSync(newPath);
    GallerySaver.saveImage(file.path);

    var stream = http.ByteStream(DelegatingStream.typed(file.openRead()));
    var length = await file.length();

    //get location info
    Position _currentPosition = await _determinePosition();

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };

    Map<String, String> mapPhoto = {
      "plans": planId,
      "photoTy": before == true ? '착수' : '완료',
      "photoLa": '${_currentPosition.latitude}',
      "photoLo": '${_currentPosition.longitude}',
    };

    if(uploadPic != null && uploadPic == true){ //일괄
      final uri = Uri.parse(BaseConfig.baseUrl+'/photos/worker');
      mapPhoto.addAll({
        "uri" : file.path,
      });
      final response = await http.post(uri,
        headers: headers,
        body: jsonEncode(mapPhoto),
      );
      if (response.statusCode >= 200 && response.statusCode <= 304) {
        //시진을 찍었으면 착수 상태로 변환
        bool? status = await changePlanStatus(planId, 'A2'); //착수
        if(status != null && status == true){
          Map<String, dynamic> map = jsonDecode(response.body);
          Photo photo = Photo.fromJson(map);
          final LocalStorage storage = LocalStorage('hms-scim');
          Map<String, String> delayImageMap = {};
          String? json = storage.getItem("delay_image_list");
          try{
            if(json != null){
              delayImageMap = jsonDecode(json).cast<String,String>();
              delayImageMap.addAll({photo.id! : photo.url!});
            }else{
              delayImageMap.addAll({photo.id! : photo.url!});
            }
            //await storage.clear();
            storage.setItem("delay_image_list", jsonEncode(delayImageMap));
          }catch(e){
            log(e.toString());
          }
          return true;
        }
      }

    }else if(uploadPic != null && uploadPic == false){ //즉시
      final uri = Uri.parse('${BaseConfig.baseUrl}/photos');
      var request = http.MultipartRequest("POST", uri);
      var multipartFile = http.MultipartFile('img', stream, length,
          filename: basename(file.path),
          contentType: MediaType('image', 'png')
      );

      request.headers.addAll(headers);
      request.files.add(multipartFile);
      request.fields.addAll(mapPhoto);
      final response = await request.send();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        bool? status = await changePlanStatus(planId, 'A2'); //착수
        if(status != null && status == true){
          return true;
        }
      }
    }
    throw Exception('error post plan photo by token');
  }

  Future<bool?> uploadPlanPhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final LocalStorage storage = LocalStorage('hms-scim');
    String? json = storage.getItem("delay_image_list");
    bool flag = false; //사진 업로드 성공한지 판단 변수

    if(json != null && json != "{}"){
      Map<String, dynamic>  delayImageMap = jsonDecode(json);
      if(delayImageMap.isNotEmpty){
        for (var key in delayImageMap.keys) {
          File image = File(delayImageMap[key]!);
          var stream = http.ByteStream(DelegatingStream.typed(image.openRead()));
          var length = await image.length();

          Map<String, String> headers = {
            "Content-Type": "application/json",
            
            "Authorization": "Bearer $token"
          };

          Map<String, String> mapPhoto = {
            "_id" : key
          };

          //사진의 ID를 통해 사진을 정보를 업로드
          final uri = Uri.parse('${BaseConfig.baseUrl}/photos/upload');
          var request = http.MultipartRequest("POST", uri);
          var multipartFile = http.MultipartFile(
              'img', stream, length,
              filename: basename(image.path),
              contentType: MediaType('image', 'png')
          );

          request.headers.addAll(headers);
          request.fields.addAll(mapPhoto);
          request.files.add(multipartFile);
          final response = await request.send();
          if (response.statusCode >= 200 && response.statusCode < 300) {
            flag = true;
          }else{
            flag = false;
          }
        }
      }
      if(flag){
        await storage.clear();
        return true;
      }
    }else{
      return false; //일관 사진을 없을 때
    }
    throw Exception('error upload plan photo by token');
  }
  
  Future<bool?> deletePlanPhoto(String photoId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final uri = Uri.parse(BaseConfig.baseUrl+"/photos/$photoId");

    final response = await http.delete(uri,
        headers: {
          "Content-Type": "application/json",
          
          "Authorization": "Bearer $token"});
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final LocalStorage storage = LocalStorage('hms-scim');
      Map<String, String> delayImageMap = {};
      String? json = storage.getItem("delay_image_list");
      try{
        if(json != null){
          delayImageMap = jsonDecode(json).cast<String,String>();
          delayImageMap.remove(photoId);
        }
        storage.setItem("delay_image_list", jsonEncode(delayImageMap));
      }catch(e){
        log(e.toString());
      }
      return true;
    }
    throw Exception('error deleting plan photo by token');
  }

  Future<Post?> saveAddInfo({required Post plan}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    Map<String, dynamic> map = {

    };

    final uri = Uri.parse(BaseConfig.baseUrl+'/plans/${plan.id}');
    final response = await http.put(uri,
      headers: {
        "Content-Type": "application/json",
        
        "Authorization": "Bearer $token"},
        body: jsonEncode(map),
    );

    if (response.statusCode >= 200 && response.statusCode <= 304) {
      Map<String, dynamic> map = jsonDecode(response.body);
      Post resPlan = Post.fromJson(map);
      return resPlan;
    }
    throw Exception('error putting plan err');
  }
}
