import 'models.dart';

class User{
  String? id;
  String? userId;
  String? userNm;
  Cmpny? cmpny;
  String? cmpnyTy;
  Cmo? cmo;
  Role? role;
  String? psitnDept;
  String? moblphonNo;
  String? telno;
  String? password;
  String? email;
  String? fax;
  String? confmer;
  String? confmDt;
  bool? useAt;
  bool? uploadedPic;
  bool? widgetMode;
  bool? widgetShootingMode;
  bool? protectMode;
  String? chargeNm;
  String? preferenceTask;
  int? loginAttempts;
  String? blockExpiresAt;
  String? createdBy;
  String? updatedBy;
  String? createdAt;
  String? updatedAt;

  User({this.useAt,this.id, this.userId,this.cmo,this.role, this.cmpny, this.cmpnyTy,
    this.chargeNm, this.protectMode, this.widgetMode, this.preferenceTask});

  User.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
      userId = json['userId'],
      userNm = json['userNm'],
      role = json['role'] != null ? Role.fromJson(json['role']) : null,
      cmo = json['cmo'] != null ? Cmo.fromJson(json['cmo']) : null,
      cmpny = json['cmpny'] != null ? Cmpny.fromJson(json['cmpny']) : null,
      cmpnyTy = json['cmpnyTy'],
      useAt = json['useAt'],
      chargeNm = json['chargeNm'],
      protectMode = json['protectMode'],
      uploadedPic = json['uploadedPic'],
      widgetMode = json['widgetMode'],
      preferenceTask = json['preferenceTask'];

  User.fromJsonOption(Map<String, dynamic> json)
      : id = json['_id'],
        userId = json['userId'],
        useAt = json['useAt'],
        chargeNm = json['chargeNm'],
        uploadedPic = json['uploadedPic'],
        protectMode = json['protectMode'],
        widgetMode = json['widgetMode'],
        preferenceTask = json['preferenceTask'];

  Map<String, dynamic> toJson() => {
    '_id' : id,
    'userId': userId,
    'role' : role,
    'cmo' : cmo,
    'cmpny' : cmpny,
    'cmpnyTy' : cmpnyTy,
    'chargeNm' : chargeNm,
    'protectMode' : protectMode,
    'widgetMode' : widgetMode,
    'preferenceTask' : preferenceTask,
    'psitnDept' : psitnDept,
    'password': password,
    'moblphonNo': moblphonNo,
    'telno': telno,
    'email': email,
    'fax': fax,
    'blockExpiresAt': blockExpiresAt,
    'confmer': confmer,
    'confmDt': confmDt,
    'widgetShootingMode': widgetShootingMode,
    'loginAttempts': loginAttempts,
    'blockExpiresAt': blockExpiresAt,
    'createdBy': createdBy,
    'updatedBy': updatedBy,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'useAt' : useAt};

}