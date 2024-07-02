// To parse this JSON data, do
//
//     final messageModel = messageModelFromJson(jsonString);

import 'dart:convert';

MessageModel messageModelFromJson(String str) => MessageModel.fromJson(json.decode(str));

String messageModelToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel {
  bool error;
  String message;
  List<Message> messages;


  MessageModel({
    required this.error,
    required this.message,
    required this.messages,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
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
  String reciverId;
  String content;
  String type;
  DateTime createdAt;
  DateTime updatedAt;
  Requirement? requirement;

  Message({
    required this.id,
    required this.senderId,
    required this.reciverId,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.requirement,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    senderId: json["senderId"],
    reciverId: json["reciverId"],
    content: json["content"],
    type: json["type"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    requirement: json["requirement"] == null ? null : Requirement.fromJson(json["requirement"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "senderId": senderId,
    "reciverId": reciverId,
    "content": content,
    "type": type,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "requirement": requirement?.toJson(),
  };
}

class Requirement {
  int id;
  String userId;
  String title;
  String description;
  String status;
  String value;
  DateTime createdAt;
  DateTime updatedAt;
  List<rImages> images;

  Requirement({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
  });

  factory Requirement.fromJson(Map<String, dynamic> json) => Requirement(
    id: json["id"],
    userId: json["user_id"],
    title: json["Title"],
    description: json["Description"],
    status: json["status"],
    value: json["value"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    images: List<rImages>.from(json["images"].map((x) => rImages.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "Title": title,
    "Description": description,
    "status": status,
    "value": value,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "images": List<dynamic>.from(images.map((x) => x.toJson())),
  };
}

class rImages {
  int id;
  String url;

  rImages({
    required this.id,
    required this.url,
  });

  factory rImages.fromJson(Map<String, dynamic> json) => rImages(
    id: json["id"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
  };
}
