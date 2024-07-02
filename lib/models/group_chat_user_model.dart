// To parse this JSON data, do
//
//     final groupChatUserModel = groupChatUserModelFromJson(jsonString);

import 'dart:convert';

GroupChatUserModel groupChatUserModelFromJson(String str) => GroupChatUserModel.fromJson(json.decode(str));

String groupChatUserModelToJson(GroupChatUserModel data) => json.encode(data.toJson());

class GroupChatUserModel {
  bool error;
  String message;
  List<RoomDetail> roomDetails;

  GroupChatUserModel({
    required this.error,
    required this.message,
    required this.roomDetails,
  });

  factory GroupChatUserModel.fromJson(Map<String, dynamic> json) => GroupChatUserModel(
    error: json["error"],
    message: json["message"],
    roomDetails: json["roomDetails"] != null ? List<RoomDetail>.from(json["roomDetails"].map((x) => RoomDetail.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "roomDetails": List<dynamic>.from(roomDetails.map((x) => x.toJson())),
  };
}

class RoomDetail {
  Room room;
  List<Participant> participants;

  RoomDetail({
    required this.room,
    required this.participants,
  });

  factory RoomDetail.fromJson(Map<String, dynamic> json) => RoomDetail(
    room: Room.fromJson(json["room"]),
    participants: List<Participant>.from(json["participants"].map((x) => Participant.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "room": room.toJson(),
    "participants": List<dynamic>.from(participants.map((x) => x.toJson())),
  };
}

class Participant {
  int id;
  String name;

  Participant({
    required this.id,
    required this.name,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class Room {
  int id;
  int userId;
  String gName;
  DateTime createdAt;
  dynamic lastMessageTime;

  Room({
    required this.id,
    required this.userId,
    required this.gName,
    required this.createdAt,
    required this.lastMessageTime,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json["id"],
    userId: json["user_id"],
    gName: json["g_name"] != null ? json["g_name"] : "Group ${json["id"]}",
    createdAt: DateTime.parse(json["created_at"]),
    lastMessageTime: json["lastMessageTime"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "g_name": gName,
    "created_at": createdAt.toIso8601String(),
    "lastMessageTime": lastMessageTime,
  };
}
