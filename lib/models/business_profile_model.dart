import 'dart:convert';

BusinessProfileModel businessProfileModelFromJson(String str) => BusinessProfileModel.fromJson(json.decode(str));

String businessProfileModelToJson(BusinessProfileModel data) => json.encode(data.toJson());

class BusinessProfileModel {
  bool error;
  String message;
  List<BusinessProfile> businessProfile;

  BusinessProfileModel({
    required this.error,
    required this.message,
    required this.businessProfile,
  });

  factory BusinessProfileModel.fromJson(Map<String, dynamic> json) => BusinessProfileModel(
    error: json["error"],
    message: json["message"],
    businessProfile: json["businessProfile"] != null ? List<BusinessProfile>.from(json["businessProfile"].map((x) => BusinessProfile.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "businessProfile": List<dynamic>.from(businessProfile.map((x) => x.toJson())),
  };
}

class BusinessProfile {
  int id;
  String userId;
  String businessName;
  String email;
  String businessType;
  String businessCategory;
  String description;
  dynamic profile;
  dynamic cover;
  DateTime createdAt;
  DateTime updatedAt;
  String name;
  String address;
  String address2;
  String state;
  String city;
  String pincode;
  String byear;
  String? homeTown;
  String phone;
  String subscriptionPlan;
  DateTime subscriptionEndDate;

  BusinessProfile({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.email,
    required this.businessType,
    required this.businessCategory,
    required this.description,
    required this.profile,
    required this.cover,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.address,
    required this.address2,
    required this.state,
    required this.city,
    required this.pincode,
    required this.byear,
    required this.homeTown,
    required this.phone,
    required this.subscriptionPlan,
    required this.subscriptionEndDate,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) => BusinessProfile(
    id: json["id"],
    userId: json["user_id"],
    businessName: json["business_name"],
    email: json["email"],
    businessType: json["business_type"],
    businessCategory: json["business_category"],
    description: json["description"],
    profile: json["profile"],
    cover: json["cover"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    name: json["NAME"],
    address: json["address"],
    address2: json["address2"],
    state: json["state"],
    city: json["city"],
    pincode: json["pincode"],
    byear: json["BYEAR"],
    phone: json["PHONE"],
    homeTown: json["homeTwon"],
    subscriptionPlan: json["subscriptionPlan"] != null ? json["subscriptionPlan"] : "",
    subscriptionEndDate: json["subscriptionEndDate"] != null ? DateTime.parse(json["subscriptionEndDate"]) : DateTime.now(),
  );


  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "business_name": businessName,
    "email": email,
    "business_type": businessType,
    "business_category": businessCategory,
    "description": description,
    "profile": profile,
    "cover": cover,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "NAME": name,
    "address": address,
    "address2": address2,
    "state": state,
    "city": city,
    "pincode": pincode,
    "BYEAR": byear,
    "PHONE": phone,
    "homeTwon": homeTown,
    "subscriptionPlan": subscriptionPlan,
    "subscriptionEndDate": "${subscriptionEndDate.year.toString().padLeft(4, '0')}-${subscriptionEndDate.month.toString().padLeft(2, '0')}-${subscriptionEndDate.day.toString().padLeft(2, '0')}",
  };
}
