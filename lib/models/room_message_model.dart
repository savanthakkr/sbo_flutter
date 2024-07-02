import 'dart:convert';

RoomMessageModel roomMessageModelFromJson(String str) => RoomMessageModel.fromJson(json.decode(str));

String roomMessageModelToJson(RoomMessageModel data) => json.encode(data.toJson());

class RoomMessageModel {
  bool error;
  String message;
  List<Message> messages;

  RoomMessageModel({
    required this.error,
    required this.message,
    required this.messages,
  });

  factory RoomMessageModel.fromJson(Map<String, dynamic> json) => RoomMessageModel(
    error: json["error"],
    message: json["message"],
    messages: List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
  };
}

class Message {
  int id;
  String senderId;
  String roomId;
  String content;
  String type;
  DateTime createdAt;
  DateTime updatedAt;

  Message({
    required this.id,
    required this.senderId,
    required this.roomId,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    senderId: json["senderId"],
    roomId: json["roomId"],
    content: json["content"],
    type: json["type"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "senderId": senderId,
    "roomId": roomId,
    "content": content,
    "type": type,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}
