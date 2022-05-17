import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:scim/src/auth/authentication_repository.dart';
import 'package:scim/src/configs/base_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/models/auth.dart';
import 'models/models.dart';

class WorkerRepository {
  AuthenticationRepository authenticationRepository = AuthenticationRepository();

  Future<List<Post>?> getListPost([int page = 1]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    Auth? auth = await authenticationRepository.getAccountInfo();
    if (auth != null) {
      final uri = Uri.parse(BaseConfig.devURL + "/posts");
      final response = await http.get(uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"}
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        Iterable body = json.decode(response.body);
        List<Post> posts = List<Post>.from(
            body.map((post) => Post.fromJson(post)));
        return posts;
      }
    }
  }

    Future<Post?> getPostById(String id) async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      Auth? auth = await authenticationRepository.getAccountInfo();
      if(auth != null){
        final uri = Uri.parse(BaseConfig.devURL+"/posts/$id");
        final response = await http.get(uri,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"}
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          Map<String, dynamic> map = jsonDecode(response.body);
          Post? post = Post.fromJson(map);
          return post;
        }
      }

    throw Exception('error getting list doing plan by token');
  }

  Future<List<Post>?> getSearchByConditions({String? roadLocation, List<String>? tags, String? fromDate, String? toDate}) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    String params = BaseConfig.devURL+
        '/posts?roadLocation=${roadLocation ?? ''}&Tag1=${tags?[0] ?? ''}&Tag2=${tags?[1] ?? ''}&Tag3=${tags?[2] ?? ''}&Tag4=${tags?[3] ?? ''}&Tag5=${tags?[4] ?? ''}';
    if(fromDate != null){
      params = params + '&fromDate=${fromDate ?? ''}';
    }
    if(toDate != null){
      params = params + '&toDate=${toDate ?? ''}';
    }
    final uri = Uri.parse(params);
    final response = await http.get(uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
    );

    if (response.statusCode >= 200 && response.statusCode <= 304) {
      Iterable body = json.decode(response.body);
      List<Post> posts = List<Post>.from(body.map((post) => Post.fromJson(post)));
      return posts;
    }

    throw Exception('error posting plan err');
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

  static Future<List<PostLocation>>? getRoadInfo(String address) async{
    String vworld = 'http://api.vworld.kr/req/search?service=search&request=search&version=2.0&size=20&page=1&query=$address&type=address&format=json&errorformat=json&key=7DE98C24-F447-3263-BD86-A3AB1E460311&category=road';

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
      List<dynamic> points = [];
      for (var element in items) {
        addresses.add(element["address"]);
        points.add(element["point"]);
      }
      List<PostLocation> postLocations = [];
      for (int i=0; i<addresses.length; i++) {
        PostLocation postLocation = PostLocation(
            postCode: addresses[i]["zipcode"],roadLocation: addresses[i]["road"],
            location: addresses[i]["parcel"], detailedLocation: addresses[i]["bldnm"],
            latitude: double.parse(points[i]["y"]), longitude: double.parse(points[i]["x"])
        );
        postLocations.add(postLocation);
      }

      return postLocations;
    }
    throw Exception('error posting plan err');
  }

  Future<List<Tag>>? getPostByParams({String? roadLocation, List<Tag>? tags}) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    String tagParams;
    if(tags != null && tags.isNotEmpty){
      tagParams = tags.join("&");
    }

    final uri = Uri.parse(BaseConfig.devURL+'/posts?roadLocation=${roadLocation ?? ''}&');
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

  Future<bool?> createNewPost(List<XFile>? images, PostLocation? postLocation, String title, String content, List<String>? tags, [isFound = false]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    List<http.MultipartFile> multipartFiles = [];

    if(images != null && images.isNotEmpty){
      for (var image in images) {
        var stream = http.ByteStream(DelegatingStream.typed(image.openRead()));
        var length = await image.length();

        multipartFiles.add(http.MultipartFile(
            'Files', stream, length,
            filename: basename(image.path),
            contentType: MediaType('image', 'png')
        ));
      }
    }

    Map<String, dynamic> mapLocation = {
      "postCode" : postLocation?.postCode ?? '',
      "roadLocation" : postLocation?.roadLocation ?? '',
      "location" : postLocation?.location ?? '',
      "detailedLocation" : postLocation?.detailedLocation ?? '',
      "extraLocation" : postLocation?.extraLocation ?? '',
      "latitude" : postLocation?.latitude?? 0,
      "longitude" : postLocation?.longitude ?? 0,
    };

    Map<String, dynamic> mapPost = {
      "title": title,
      "content": content,
      "isFound" : isFound,
      "postLocation": mapLocation,
    };

    if(tags != null){
      int i = tags.length;
      for(i; i<5; i++){
        tags.add("");
      }
    }

    Map<String, dynamic> mapTags(value) => {
      "tagName" : value
    };

    Map<String, String> mapFields = {
      "Post" : jsonEncode(mapPost),
      "Tag1" : jsonEncode(mapTags(tags?[0] ?? '')),
      "Tag2" : jsonEncode(mapTags(tags?[1] ?? '')),
      "Tag3" : jsonEncode(mapTags(tags?[2] ?? '')),
      "Tag4" : jsonEncode(mapTags(tags?[3] ?? '')),
      "Tag5" : jsonEncode(mapTags(tags?[4] ?? '')),
    };

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };

    final uri = Uri.parse('${BaseConfig.devURL}/posts');
    var request = http.MultipartRequest("POST", uri);

    request.headers.addAll(headers);
    request.fields.addAll(mapFields);
    request.files.addAll(multipartFiles);
    final response = await request.send();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    throw Exception('error upload plan photo by token');
  }

  //to get address text and point from vworld
  Future<Position> determinePosition() async {
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

  Future<bool?> deletePost(String postId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final uri = Uri.parse(BaseConfig.devURL+"/posts/$postId");
    final response = await http.delete(uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"}
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    throw Exception('error getting list doing plan by token');
  }
}
