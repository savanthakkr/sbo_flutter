// To parse this JSON data, do
//
//     final sellItModel = sellItModelFromJson(jsonString);

import 'dart:convert';

SellItModel sellItModelFromJson(String str) => SellItModel.fromJson(json.decode(str));

String sellItModelToJson(SellItModel data) => json.encode(data.toJson());

class SellItModel {
  bool error;
  String message;
  List<SellIt> sellit;

  SellItModel({
    required this.error,
    required this.message,
    required this.sellit,
  });

  factory SellItModel.fromJson(Map<String, dynamic> json) => SellItModel(
    error: json["error"],
    message: json["message"],
    sellit: List<SellIt>.from(json["messages"].map((x) => SellIt.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "messages": List<dynamic>.from(sellit.map((x) => x.toJson())),
  };
}

class SellIt {
  int id;
  String userId;
  String requirementUserId;
  String requirementId;
  DateTime createdAt;
  DateTime updatedAt;

  SellIt({
    required this.id,
    required this.userId,
    required this.requirementUserId,
    required this.requirementId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SellIt.fromJson(Map<String, dynamic> json) => SellIt(
    id: json["id"],
    userId: json["user_id"],
    requirementUserId: json["requirement_user_id"],
    requirementId: json["requirement_id"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "requirement_user_id": requirementUserId,
    "requirement_id": requirementId,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
