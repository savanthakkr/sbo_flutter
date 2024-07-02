import 'dart:convert';

ChatUserModel chatUserModelFromJson(String str) => ChatUserModel.fromJson(json.decode(str));

String chatUserModelToJson(ChatUserModel data) => json.encode(data.toJson());

class ChatUserModel {
  bool error;
  String message;
  List<ChatUser> chatUser;

  ChatUserModel({
    required this.error,
    required this.message,
    required this.chatUser,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) => ChatUserModel(
    error: json["error"],
    message: json["message"],
    chatUser: json["chatUsers"] != null ? List<ChatUser>.from(json["chatUsers"].map((x) => ChatUser.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "chatUser": List<dynamic>.from(chatUser.map((x) => x.toJson())),
  };
}

class ChatUser {
  int id;
  String name;
  String batchYear;
  String mobileNumber;
  String type;
  String status;
  DateTime createdAt;
  DateTime updatedAt;
  int unseenMessagesCount;
  DateTime lastMessageTime;
  String? image;
  String? category;
  bool? isSelect;

  ChatUser({
    required this.id,
    required this.name,
    required this.batchYear,
    required this.mobileNumber,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.unseenMessagesCount,
    required this.lastMessageTime,
    required this.image,
    required this.category,
    this.isSelect,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
    id: json["id"],
    name: json["name"],
    batchYear: json["batchYear"],
    mobileNumber: json["mobileNumber"],
    type: json["type"],
    status: json["status"],
    createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : DateTime.now(),
    updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : DateTime.now(),
    unseenMessagesCount: json["unseenMessagesCount"] != null ? json["unseenMessagesCount"] : 0,
    lastMessageTime: json["lastMessageTime"] != null ? DateTime.parse(json["lastMessageTime"]) : DateTime.parse(json["created_at"]),
    image: json["image"] != null ? json["image"] : "",
    category: json["category"] != null ? json["category"] : "",
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
    "unseenMessagesCount": unseenMessagesCount,
    "lastMessageTime": lastMessageTime.toIso8601String(),
    "image": image,
    "category": category,
  };
}
