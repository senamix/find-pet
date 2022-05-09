
import 'package:equatable/equatable.dart';

class PostLocation extends Equatable{
  int? id;
  String? postCode;
  String? roadLocation;
  String? location;
  String? detailedLocation;
  String? extraLocation;
  double? longitude;
  double? latitude;

  PostLocation({this.id});

  PostLocation.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      postCode = json['postCode'],
      roadLocation = json['roadLocation'],
      location = json['location'],
      detailedLocation = json['detailedLocation'],
      extraLocation = json['extraLocation'],
      longitude = json['longitude'],
      latitude = json['latitude']
  ;

  Map<String, dynamic> toJson() => {
    'id': id,
    'postCode': postCode,
    'roadLocation' : roadLocation,
    'location' : location,
    'detailedLocation' : detailedLocation,
    'extraLocation' : extraLocation,
    'longitude' : longitude,
    'latitude' : latitude
  };

  @override
  List<Object> get props => [id!];
}
