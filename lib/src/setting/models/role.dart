class Role{
  String? id;
  String? roleCode;
  String? roleNm;
  String? roleTy;
  bool? useAt;
  String? createdAt;
  String? updatedAt;

  Role({this.id, this.roleCode, this.roleNm, this.roleTy, this.useAt});

  Role.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        roleCode = json['roleCode'],
        roleNm = json['roleNm'],
        roleTy = json['roleTy'],
        useAt = json['useAt'];

  Map<String, dynamic> toJson() => {
    '_id': id,
    'rolCode': roleCode,
    'roleNm' : roleNm,
    'roleTy' : roleTy,
    'useAt' : useAt};
}