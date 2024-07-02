import 'dart:convert';

UserTokenModel userTokenModelFromJson(String str) => UserTokenModel.fromJson(json.decode(str));

String userTokenModelToJson(UserTokenModel data) => json.encode(data.toJson());

class UserTokenModel {
  bool error;
  String message;
  List<UserToken> userToken;

  UserTokenModel({
    required this.error,
    required this.message,
    required this.userToken,
  });

  factory UserTokenModel.fromJson(Map<String, dynamic> json) => UserTokenModel(
    error: json["error"],
    message: json["message"],
    userToken: json["UserToken"] != null ? List<UserToken>.from(json["UserToken"].map((x) => UserToken.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "UserToken": List<dynamic>.from(userToken.map((x) => x.toJson())),
  };
}

class UserToken {
  String token;

  UserToken({
    required this.token,
  });

  factory UserToken.fromJson(Map<String, dynamic> json) => UserToken(
    token: json["token"] != null ? json["token"] : "",
  );

  Map<String, dynamic> toJson() => {
    "token": token,
  };
}
