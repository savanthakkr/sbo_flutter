import 'dart:convert';

UserPlanModel userPlanModelFromJson(String str) => UserPlanModel.fromJson(json.decode(str));

String userPlanModelToJson(UserPlanModel data) => json.encode(data.toJson());

class UserPlanModel {
  bool error;
  String message;
  List<UserPlan> userPlan;

  UserPlanModel({
    required this.error,
    required this.message,
    required this.userPlan,
  });

  factory UserPlanModel.fromJson(Map<String, dynamic> json) => UserPlanModel(
    error: json["error"],
    message: json["message"],
    userPlan: json["UserPlan"] != null ? List<UserPlan>.from(json["UserPlan"].map((x) => UserPlan.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "UserPlan": List<dynamic>.from(userPlan.map((x) => x.toJson())),
  };
}

class UserPlan {
  String subscriptionPlan;
  String status;

  UserPlan({
    required this.subscriptionPlan,
    required this.status,
  });

  factory UserPlan.fromJson(Map<String, dynamic> json) => UserPlan(
    subscriptionPlan: json["subscriptionPlan"] != null ? json["subscriptionPlan"] : "",
    status: json["status"] != null ? json["status"] : "0",
  );

  Map<String, dynamic> toJson() => {
    "subscriptionPlan": subscriptionPlan,
    "status": status,
  };
}
