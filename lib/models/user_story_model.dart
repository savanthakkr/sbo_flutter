import 'dart:convert';

UserStoryModel userStoryModelFromJson(String str) => UserStoryModel.fromJson(json.decode(str));

String userStoryModelToJson(UserStoryModel data) => json.encode(data.toJson());

class UserStoryModel {
  bool error;
  String message;
  List<UserStory> userStory;

  UserStoryModel({
    required this.error,
    required this.message,
    required this.userStory,
  });

  factory UserStoryModel.fromJson(Map<String, dynamic> json) => UserStoryModel(
    error: json["error"],
    message: json["message"],
    userStory: json["UserStory"] != null ? List<UserStory>.from(json["UserStory"].map((x) => UserStory.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "UserStory": List<dynamic>.from(userStory.map((x) => x.toJson())),
  };
}

class UserStory {
  int id;
  String userId;
  String photo;
  String storyTime;
  String status;
  DateTime createdAt;
  DateTime updatedAt;

  UserStory({
    required this.id,
    required this.userId,
    required this.photo,
    required this.storyTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserStory.fromJson(Map<String, dynamic> json) => UserStory(
    id: json["id"],
    userId: json["user_id"],
    photo: json["photo"],
    storyTime: json["story_time"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "photo": photo,
    "story_time": storyTime,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
