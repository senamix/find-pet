import 'package:equatable/equatable.dart';
import 'package:scim/src/worker/models/models.dart';

import '../../auth/models/auth.dart';

class Post extends Equatable {
  String? id;
  String? title;
  String? content;
  String? date;
  bool? isFound;
  PostLocation? postLocation;
  List<Photo>? photos;
  List<Auth>? postParticipants;
  String? posterName;
  String? createdAt;

  Post({this.id, this.title});

  Post.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      title = json['title'],
      content = json['content'],
      date = json['date'],
      postLocation = json['postLocation'] != null ? PostLocation.fromJson(json['postLocation']) : null,
      photos = json['photos'] != List.empty() ? List<Photo>.from(json['photos'].map((photo) => Photo.fromJson(photo))) : List.empty(),
      postParticipants = json['postParticipants'] != null ? List<Auth>.from(json['postParticipants'].map((item) => Auth.fromJson(item))) : List.empty(),
      isFound = json['isFound'],
      posterName = json['posterName'],
      createdAt = json['createdAt']
  ;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content' : content,
    'date' : date,
    'posterName' : posterName,
    'postLocation' : postLocation,
    'postParticipants' : postParticipants,
    'isFound' : isFound
  };

  @override
  List<Object> get props => [id!];
}