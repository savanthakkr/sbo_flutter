import 'dart:convert';

RoomUserTokenModel roomUserTokenModelFromJson(String str) => RoomUserTokenModel.fromJson(json.decode(str));

String roomUserTokenModelToJson(RoomUserTokenModel data) => json.encode(data.toJson());

class RoomUserTokenModel {
  bool error;
  String message;
  List<RoomUserToken> roomUserToken;

  RoomUserTokenModel({
    required this.error,
    required this.message,
    required this.roomUserToken,
  });

  factory RoomUserTokenModel.fromJson(Map<String, dynamic> json) => RoomUserTokenModel(
    error: json["error"],
    message: json["message"],
    roomUserToken: json["roomUserToken"] != null ? List<RoomUserToken>.from(json["roomUserToken"].map((x) => RoomUserToken.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "roomUserToken": List<dynamic>.from(roomUserToken.map((x) => x.toJson())),
  };
}

class RoomUserToken {
  List<AllUserToken> allUserToken;

  RoomUserToken({
    required this.allUserToken,
  });

  factory RoomUserToken.fromJson(Map<String, dynamic> json) => RoomUserToken(
    allUserToken: List<AllUserToken>.from(json["allUserToken"].map((x) => AllUserToken.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "allUserToken": List<dynamic>.from(allUserToken.map((x) => x.toJson())),
  };
}

class AllUserToken {
  String? token;

  AllUserToken({
    required this.token,
  });

  factory AllUserToken.fromJson(Map<String, dynamic> json) => AllUserToken(
    token: json["token"] != null ? json["token"] : "",
  );

  Map<String, dynamic> toJson() => {
    "token": token,
  };
}
