import 'dart:convert';

UserListModel userListModelFromJson(String str) => UserListModel.fromJson(json.decode(str));

String userListModelToJson(UserListModel data) => json.encode(data.toJson());

class UserListModel {
  bool error;
  String message;
  List<AllUser> allUsers;
  int userCount;

  UserListModel({
    required this.error,
    required this.message,
    required this.allUsers,
    required this.userCount,
  });

  factory UserListModel.fromJson(Map<String, dynamic> json) => UserListModel(
    error: json["error"],
    message: json["message"],
    allUsers: json["allUsers"] != null ? List<AllUser>.from(json["allUsers"].map((x) => AllUser.fromJson(x))) : [],
    userCount: json["userCount"] != null ? json["userCount"] : 0,
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "allUsers": List<dynamic>.from(allUsers.map((x) => x.toJson())),
    "userCount": userCount,
  };
}

class AllUser {
  int id;
  String name;
  String batchYear;
  String mobileNumber;
  String type;
  String status;
  DateTime createdAt;
  DateTime updatedAt;
  int fId;
  String fStatus;
  String image;
  String category;
  String reqId;

  AllUser({
    required this.id,
    required this.name,
    required this.batchYear,
    required this.mobileNumber,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.fId,
    required this.fStatus,
    required this.image,
    required this.category,
    required this.reqId,
  });

  factory AllUser.fromJson(Map<String, dynamic> json) => AllUser(
    id: json["id"],
    name: json["name"],
    batchYear: json["batchYear"],
    mobileNumber: json["mobileNumber"],
    type: json["type"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    fId: json["FID"] != null ? json["FID"] : 0,
    fStatus: json["FSTATUS"] != null ? json["FSTATUS"] : "-1",
    image: json["image"] != null ? json["image"] : "",
    category: json["category"] != null ? json["category"] : "",
    reqId: json["REQID"] != null ? json["REQID"] : "0",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "batchYear": batchYear,
    "mobileNumber": mobileNumber,
    "type": type,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "FID": fId,
    "FSTATUS": fStatus,
    "image": image,
    "category": category,
    "REQID": reqId,
  };
}
