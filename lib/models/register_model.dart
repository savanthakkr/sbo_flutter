import 'dart:convert';

RegisterModel registerModelFromJson(String str) => RegisterModel.fromJson(json.decode(str));

String registerModelToJson(RegisterModel data) => json.encode(data.toJson());

class RegisterModel {
  bool error;
  String message;
  int userId;

  RegisterModel({
    required this.error,
    required this.message,
    required this.userId,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
    error: json["error"],
    message: json["message"],
    userId: json["userId"] !=null ? json["userId"] : 0,
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "userId": userId,
  };
}
