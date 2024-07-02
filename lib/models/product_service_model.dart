import 'dart:convert';

ProductServiceModel productServiceModelFromJson(String str) => ProductServiceModel.fromJson(json.decode(str));

String productServiceModelToJson(ProductServiceModel data) => json.encode(data.toJson());

class ProductServiceModel {
  bool error;
  String message;
  List<AllProductService> allProductService;
  // ProductServiceModel
  ProductServiceModel({
    required this.error,
    required this.message,
    required this.allProductService,
  });

  factory ProductServiceModel.fromJson(Map<String, dynamic> json) => ProductServiceModel(
    error: json["error"],
    message: json["message"],
    allProductService: json["allProducts"] != null ? List<AllProductService>.from(json["allProducts"].map((x) => AllProductService.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "allProductService": List<dynamic>.from(allProductService.map((x) => x.toJson())),
  };
}

class AllProductService {
  String userId;
  dynamic id;
  String title;
  String description;
  String status;
  DateTime createdAt;
  DateTime updatedAt;
  List<Images> images;

  AllProductService({
    required this.userId,
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
  });

  factory AllProductService.fromJson(Map<String, dynamic> json) => AllProductService(
    userId: json["user_id"],
    id: json["id"],
    title: json["Title"],
    description: json["Description"],
    status: json["status"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    images: json["images"] != null ? List<Images>.from(json["images"].map((x) => Images.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "Title": title,
    "id": id,
    "Description": description,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "images": List<dynamic>.from(images.map((x) => x.toJson())),
  };
}

class Images {
  int id;
  String url;

  Images({
    required this.id,
    required this.url,
  });

  factory Images.fromJson(Map<String, dynamic> json) => Images(
    id: json["id"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
  };
}
