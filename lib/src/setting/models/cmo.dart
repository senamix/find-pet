class Cmo{
  String? id;
  String? cmoCode;
  String? cmoGrpNm;
  String? cmoNm;
  bool? useAt;
  String? cmoOrgCode;
  String? createdBy;
  String? updatedBy;
  DateTime? createdAt;
  DateTime? updatedAt;

  Cmo({this.id, this.cmoCode, this.cmoOrgCode, this.cmoNm, this.useAt});

  Cmo.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        cmoCode = json['cmoCode'],
        cmoOrgCode = json['cmoOrgCode'],
        cmoNm = json['cmoNm'],
        useAt = json['useAt'];

  Map<String, dynamic> toJson() => {
    '_id': id,
    'cmoCode': cmoCode,
    'cmoOrgCode' : cmoOrgCode,
    'cmoNm' : cmoNm,
    'useAt' : useAt};

}