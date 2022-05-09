import 'models.dart';

class Tag{
  String? id;
  String? tagName;
  List<Post>? posts;

  Tag({this.id});

  Tag.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        tagName = json['tagName'],
        posts = json['posts'] != List.empty() ? List<Post>.from(json['posts'].map((item) => Post.fromJson(item))) : List.empty()
  ;

  Map<String, dynamic> toJson = {
  };
}
