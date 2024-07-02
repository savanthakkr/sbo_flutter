// To parse this JSON data, do
//
//     final personalProfileModel = personalProfileModelFromJson(jsonString);

import 'dart:convert';

PersonalProfileModel personalProfileModelFromJson(String str) => PersonalProfileModel.fromJson(json.decode(str));

String personalProfileModelToJson(PersonalProfileModel data) => json.encode(data.toJson());

class PersonalProfileModel {
  bool error;
  String message;
  List<PersonalProfile> personalProfile;

  PersonalProfileModel({
    required this.error,
    required this.message,
    required this.personalProfile,
  });

  factory PersonalProfileModel.fromJson(Map<String, dynamic> json) => PersonalProfileModel(
    error: json["error"],
    message: json["message"],
    personalProfile: json["personalProfile"] != null ? List<PersonalProfile>.from(json["personalProfile"].map((x) => PersonalProfile.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "personalProfile": List<dynamic>.from(personalProfile.map((x) => x.toJson())),
  };
}

class PersonalProfile {
  int id;
  String userId;
  String email;
  String qualification;
  String qAddress;
  String occupation;
  String oAddress;
  String employment;
  String about;
  dynamic profile;
  dynamic cover;
  String address;
  String homeTown;
  DateTime createdAt;
  DateTime updatedAt;
  String name;
  String byear;
  String phone;

  PersonalProfile({
    required this.id,
    required this.userId,
    required this.email,
    required this.qualification,
    required this.qAddress,
    required this.occupation,
    required this.oAddress,
    required this.employment,
    required this.about,
    required this.profile,
    required this.cover,
    required this.address,
    required this.homeTown,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.byear,
    required this.phone,
  });

  factory PersonalProfile.fromJson(Map<String, dynamic> json) => PersonalProfile(
    id: json["id"],
    userId: json["user_id"],
    email: json["email"],
    qualification: json["qualification"],
    qAddress: json["qAddress"],
    occupation: json["occupation"],
    oAddress: json["oAddress"],
    employment: json["employment"],
    about: json["about"],
    profile: json["profile"] != null ? json["profile"] : null,
    cover: json["cover"] != null ? json["cover"] : null,
    address: json["address"] != null ? json["address"] : "",
    homeTown: json["homeTown"] != null ? json["homeTown"] : "",
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    name: json["NAME"],
    byear: json["BYEAR"],
    phone: json["PHONE"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "email": email,
    "qualification": qualification,
    "qAddress": qAddress,
    "occupation": occupation,
    "oAddress": oAddress,
    "employment": employment,
    "about": about,
    "profile": profile,
    "cover": cover,
    "address": address,
    "homeTown": homeTown,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "NAME": name,
    "BYEAR": byear,
    "PHONE": phone,
  };
}
