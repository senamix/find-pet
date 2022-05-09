class Photo {

  String? id;
  String? url;

  Photo({this.id});

  Photo.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      url = json['url']
  ;

  Map<String, dynamic> toJson =
    {
    };
}