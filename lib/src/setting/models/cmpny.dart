import 'cmpnyTy.dart';

class Cmpny{
  String? id;
  String? cmpnyTy;
  String? cmpnyNm;
  String? rprsntv;
  String? bizrno;
  String? telno;
  String? fax;
  String? confmer;
  DateTime? confmDt;
  bool? useAt;
  String? createdBy;
  String? updatedBy;
  DateTime? createdAt;
  DateTime? updatedAt;

  Cmpny({this.id, this.cmpnyTy, this.cmpnyNm, this.useAt});

  Cmpny.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        cmpnyTy = json['cmpnyTy'],
        cmpnyNm = json['cmpnyNm'],
        useAt = json['useAt'];

  Map<String, dynamic> toJson() => {
    '_id': id,
    'cmpnyTy': cmpnyTy,
    'cmpnyNm' : cmpnyNm,
    'useAt' : useAt};

}