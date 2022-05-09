class CmpnyTy{
  String? id;
  String? cmpnyTyCode;
  String? cmpnyTyNm;
  bool? useAt;
  String? createdBy;
  String? updatedBy;
  DateTime? createdAt;
  DateTime? updatedAt;

  CmpnyTy({this.id, this.cmpnyTyCode, this.cmpnyTyNm, this.useAt});

  CmpnyTy.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        cmpnyTyCode = json['cmpnyTyCode'],
        cmpnyTyNm = json['cmpnyTyNm'],
        useAt = json['useAt'];

  Map<String, dynamic> toJson() => {
    '_id': id,
    'cmpnyTyCode': cmpnyTyCode,
    'cmpnyTyNm' : cmpnyTyNm,
    'useAt' : useAt};
}