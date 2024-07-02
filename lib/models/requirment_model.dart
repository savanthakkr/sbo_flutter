import 'dart:convert';

RequirmentModel requirmentModelFromJson(String str) => RequirmentModel.fromJson(json.decode(str));

String requirmentModelToJson(RequirmentModel data) => json.encode(data.toJson());

class RequirmentModel {
  bool error;
  String message;
  List<AllRequirment> allRequirment;

  RequirmentModel({
    required this.error,
    required this.message,
    required this.allRequirment,
  });

  factory RequirmentModel.fromJson(Map<String, dynamic> json) => RequirmentModel(
    error: json["error"],
    message: json["message"],
    allRequirment: json["allRequirment"] != null ? List<AllRequirment>.from(json["allRequirment"].map((x) => AllRequirment.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "allRequirment": List<dynamic>.from(allRequirment.map((x) => x.toJson())),
  };
}

class AllRequirment {
  String userId;
  dynamic id;
  String title;
  String description;
  String status;
  String value;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic profile;
  String userName;
  String userType;
  bool isSaved;
  List<Imagess> images;
  int? userCount;

  AllRequirment({
    required this.userId,
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
    required this.profile,
    required this.userName,
    required this.userType,
    required this.isSaved,
    required this.images,
    required this.userCount,
  });

  factory AllRequirment.fromJson(Map<String, dynamic> json) => AllRequirment(
    userId: json["user_id"],
    id: json["id"],
    title: json["Title"],
    description: json["Description"],
    status: json["status"],
    value: json["value"] != null ? json["value"] : "Now",
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    profile: json["profile"] != null ? json["profile"] : null,
    userName: json["userName"] != null ? json["userName"] : "",
    userType: json["userType"] != null ? json["userType"] : "",
    isSaved: json["isSaved"] != null ? json["isSaved"] : false,
    images: json["images"] != null ? List<Imagess>.from(json["images"].map((x) => Imagess.fromJson(x))) : [],
    userCount: json["userCount"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "Title": title,
    "id": id,
    "Description": description,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "profile": profile,
    "userName": userName,
    "userType": userType,
    "isSaved": isSaved,
    "images": List<dynamic>.from(images.map((x) => x.toJson())),
    "userCount": userCount,
  };
}

class Imagess {
  int id;
  String url;

  Imagess({
    required this.id,
    required this.url,
  });

  factory Imagess.fromJson(Map<String, dynamic> json) => Imagess(
    id: json["id"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
  };
}
