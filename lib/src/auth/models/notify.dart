import 'models.dart';

class Notify{
  String? content;
  String? id;
  String? createdAt;
  String? updatedAt;

  Notify(this.content, this.id, this.createdAt, this.updatedAt);

  Notify.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        content = json['content'],
        createdAt = json['createdAt'],
        updatedAt = json['updatedAt'];

  Map<String, dynamic> toJson() => {
    '_id': id,
    'content': content,
    'createdAt': createdAt,
    'updatedAt': updatedAt
  };
}