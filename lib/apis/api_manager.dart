import 'dart:convert';

import 'package:sbo/models/business_profile_model.dart';
import 'package:sbo/models/chat_user_model.dart';
import 'package:sbo/models/group_chat_user_model.dart';
import 'package:sbo/models/login_model.dart';
import 'package:sbo/models/message_model.dart';
import 'package:sbo/models/personal_profile_model.dart';
import 'package:sbo/models/product_service_model.dart';
import 'package:sbo/models/register_model.dart';
import 'package:http/http.dart' as http;
import 'package:sbo/models/requirment_model.dart';
import 'package:sbo/models/result_model.dart';
import 'package:sbo/models/room_message_model.dart';
import 'package:sbo/models/room_user_token.dart';
import 'package:sbo/models/sell_it_model.dart';
import 'package:sbo/models/user_list_model.dart';
import 'package:sbo/models/user_plan_model.dart';
import 'package:sbo/models/user_token_model.dart';

import '../models/message_model.dart';
import '../models/user_story_model.dart';

class ApiManager {

  static String baseUrl = "http://3.110.124.116:3300/api/";

  // static String baseUrl = "http://3.110.185.95:3333/api/";
  // static String baseUrl = "https://sbo.onrender.com/api/";
  // static String baseUrl = "http://192.168.42.193:3300/api/";


  static Future<RegisterModel> CreateUser(String name,String byear,String yearTo, String mobile) async {

    final response = await http.post(Uri.parse("${baseUrl}users/register"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "name" : name,
          "batchYear" : byear,
          "yearTo": yearTo,
          "mobileNumber" : mobile,
        }));

    return registerModelFromJson(response.body);
  }



  static Future<ResultModel> UpdateUserSubscription( int userid, String subscriptionPlan) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/updateUserSubscription"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId" : userid,
          "subscriptionPlan" : subscriptionPlan,
        }));

    return resultModelFromJson(response.body);
  }


  static Future<ResultModel> UpdateGroupName( String userid, String roomId, String name) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/updateGroupName"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "roomId" : roomId,
          "userId" : userid,
          "name" : name,
        }));

    return resultModelFromJson(response.body);
  }

  static Future<ResultModel> UpdateUserName( String userid, String name, String batchYear, String yearTo) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/updateUserName"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId" : userid,
          "name" : name,
          "batchYear" : batchYear,
          "yearTo": yearTo,
        }));


    print(response.body);

    return resultModelFromJson(response.body);
  }


  static Future<ResultModel> UpdateUserType(String type,int userid) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/updateType"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "type" : type,
          "userId" : userid,
        }));

    return resultModelFromJson(response.body);
  }

  static Future<ResultModel> CreatePersonalProfile(String userId,String email,String qualification,String cityQualification,
      String occupdation,String cityOccupdation,String employment,String about,String profile,String cover,String address, String homeTown) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/createProfile"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId" : userId,
          "email" : email,
          "qualification" : qualification,
          "cityQualification" : cityQualification,
          "occupation" : occupdation,
          "cityOccupation" : cityOccupdation,
          "employment" : employment,
          "about" : about,
          "profile" : profile,
          "cover" : cover,
          "address" : address,
          "homeTown": homeTown,
        }));

    return resultModelFromJson(response.body);
  }

  static Future<ResultModel> createStory(String userId,String profile,String time) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/createStory"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId" : userId,
          "profile" : profile,
          "time" : time,
        }));

    return resultModelFromJson(response.body);
  }


  static Future<ResultModel> CreateBusinessProfile(String userId,String email,String businessname,
      String businesstype,String businesscategory,String about,String profile,String cover, String address,String address2,String state,String city,String pinCode, String homeTwon) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/createBusinessProfile"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId" : userId,
          "business_name" : businessname,
          "email" : email,
          "business_type" : businesstype,
          "business_category" : businesscategory,
          "description" : about,
          "profile" : profile,
          "cover" : cover,
          "address": address,
          "address2": address2,
          "state": state,
          "city": city,
          "pinCode": pinCode,
          "homeTwon": homeTwon
        }));

    return resultModelFromJson(response.body);
  }


  static Future<ResultModel> EditBusinessProfile(String userId,String email,String businessname,
      String businesstype,String businesscategory,String about,String profile,String cover, String address,String address2,String state,String city,String pinCode, String homeTwon) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/updateBusinessProfile"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId" : userId,
          "business_name" : businessname,
          "email" : email,
          "business_type" : businesstype,
          "business_category" : businesscategory,
          "description" : about,
          "profile" : profile,
          "cover" : cover,
          "address": address,
          "address2": address2,
          "state": state,
          "city": city,
          "pinCode": pinCode,
          "homeTwon": homeTwon
        }));

    return resultModelFromJson(response.body);
  }

  static Future<ResultModel> EditPersonalProfile(String userId,String email,
      String qualification,String cityQualification,String occupation,String cityOccupation,String employment,String about,String profile,String cover, String address, String homeTown) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/updateUserPersonalProfile"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId" : userId,
          "email" : email,
          "qualification": qualification,
          "cityQualification": cityQualification,
          "occupation": occupation,
          "cityOccupation": cityOccupation,
          "employment": employment,
          "about" : about,
          "profile" : profile,
          "cover" : cover,
          "address": address,
          "homeTown": homeTown
        }));

    return resultModelFromJson(response.body);
  }

  static Future<LoginModel> UserLogin(String mobile) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/login"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "mobileNumber" : mobile,
        }));

    return loginModelFromJson(response.body);
  }

  static Future<ResultModel> AddRequirements(String userId,String title, String description,List<String> images, String _radioValue) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/createRequirement"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
          'title': title,
          'description': description,
          'images': images,
          'value': _radioValue,
        }));

    return resultModelFromJson(response.body);
  }

  static Future<ResultModel> UpdateRequirements(String requirmentId,String title, String description,List<String> images, String _radioValue) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/updateRequirement"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "requirementId": requirmentId,
          'title': title,
          'description': description,
          'images': images,
          'value': _radioValue,
        }));

    return resultModelFromJson(response.body);
  }

  static Future<ResultModel> deleteimageRequirements(String imageId) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/deleteImage"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "imageId": imageId,
        }));

    return resultModelFromJson(response.body);
  }


  static Future<ResultModel> UpdateProductService(String productId,String title, String description,List<String> images) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/updateProductService"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "productId": productId,
          'title': title,
          'description': description,
          'images': images,
        }));

    return resultModelFromJson(response.body);
  }

  static Future<ResultModel> deleteimageProductService(String imageId) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/deleteImageProductService"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "imageId": imageId,
        }));

    return resultModelFromJson(response.body);
  }


  static Future<ResultModel> saveRequirements(String userId,String id, String rUserId) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/saveRequirement"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
          'requirementId': id,
          'requirementUserId': rUserId,
        }));

    return resultModelFromJson(response.body);
  }

  static Future<ResultModel> DeleteRequirements(String requirementId) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/deleteRequirement"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "requirementId": requirementId,
        }));

    return resultModelFromJson(response.body);
  }
  static Future<ResultModel> UpdateRequirementsStatus(String requirementId) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/updateRequirementStatus"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "requirementId": requirementId,
        }));

    return resultModelFromJson(response.body);
  }

  static Future<UserListModel> FetchAllUsers(String userId) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/fetchAllUsers"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
        }));

    return userListModelFromJson(response.body);
  }

  static Future<RequirmentModel> FetchUserRequirment(String userId) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/fetchAllUserRequirments"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
        }));

    return requirmentModelFromJson(response.body);
  }

  static Future<RequirmentModel> FetchFollowUserRequirment(String userId) async {

    final response = await http.post(Uri.parse("${baseUrl}users/fetchAllUserRequirementsUserFollo"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
        }));

    print(response.body);

    return requirmentModelFromJson(response.body);
  }


  static Future<RequirmentModel> FetchSavedUserRequirment(String userId) async {

    final response = await http.post(Uri.parse("${baseUrl}users/getSavedRequirements"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
        }));


    print(response.body);

    return requirmentModelFromJson(response.body);
  }

  static Future<PersonalProfileModel> FetchPersonalProfile(String userId) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/fetchPersonalProfile"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
        }));

    print(response.body);

    return personalProfileModelFromJson(response.body);
  }

  static Future<BusinessProfileModel> FetchBusinessProfile(String userId) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/fetchBusinessProfile"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
        }));

    return businessProfileModelFromJson(response.body);
  }

  static Future<ResultModel> SendFollowRequest(String userId,String followerId) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/sendFollowRequest"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
          'followerId': followerId,
        }));

    return resultModelFromJson(response.body);
  }

  static Future<ResultModel> UpdateFollowRequest(String reqId,String status) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/updateRequestStatus"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "reqId": reqId,
          'status': status,
        }));

    return resultModelFromJson(response.body);
  }

  static Future<ResultModel> UpdateUserToken(String token,dynamic userid) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/updateToken"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "token" : token,
          "userId" : userid,
        }));

    return resultModelFromJson(response.body);
  }


  static Future<UserTokenModel> GetUserToken(dynamic userid) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/getToken"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId" : userid,
        }));

    return userTokenModelFromJson(response.body);
  }

  static Future<RoomUserTokenModel> GetRoomUserToken(dynamic userid) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/getRoomToken"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "roomId" : userid,
        }));

    return roomUserTokenModelFromJson(response.body);
  }

  static Future<ChatUserModel> fetchChatUser(String userId) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/getAllUsersIfFollow"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
        }));

    return chatUserModelFromJson(response.body);
  }

  static Future<ResultModel> CreateGroup(String userId,List<dynamic> selectedUsers) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/createRoom"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
          "selectedUsers": selectedUsers,
        }));


    return resultModelFromJson(response.body);
  }

  static Future<GroupChatUserModel> FetchGroupChats(String userId) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/findRoomByUserId"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
        }));

    print(response.body);

    return groupChatUserModelFromJson(response.body);
  }


  static Future<MessageModel> fetchMessage(String userId, String receiverId) async {
    final response = await http.post(
      Uri.parse("${baseUrl}users/getMessages"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "senderId": userId,
        "receiverId": receiverId,
      }),
    );

    print(response.body);

    return messageModelFromJson(response.body);
  }

  static Future<RoomMessageModel> fetchMessageRoom( String roomId) async {
    final response = await http.post(
      Uri.parse("${baseUrl}users/getMessagesRoom"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "roomId": roomId,
      }),
    );

    return roomMessageModelFromJson(response.body);
  }
  static Future<ResultModel> sendMessageAsSeen(String userId,String receiverId) async {
    final response = await http.post(
      Uri.parse("${baseUrl}users/markMessagesAsSeen"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "senderId": userId,
        "receiverId": receiverId,
      }),
    );

    return resultModelFromJson(response.body);
  }

  static Future<ResultModel> sendMessage(String userId, String content,String type, String receiverId) async {
    final response = await http.post(
      Uri.parse("${baseUrl}users/sendMessage"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "senderId": userId,
        "content": content,
        "receiverId": receiverId,
        "type": type,
      }),
    );

    return resultModelFromJson(response.body);
  }

  static Future<ResultModel> ClickSellIt(String user_id, String requirement_user_id,String requirement_id) async {
    final response = await http.post(
      Uri.parse("${baseUrl}users/clickSellIt"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": user_id,
        "requirement_user_id": requirement_user_id,
        "requirement_id": requirement_id,
      }),
    );

    return resultModelFromJson(response.body);
  }


  static Future<SellItModel> fetchClickSellIt(String user_id, String requirement_user_id) async {
    final response = await http.post(
      Uri.parse("${baseUrl}users/getClickSellIt"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": user_id,
        "requirement_user_id": requirement_user_id,
      }),
    );

    return sellItModelFromJson(response.body);
  }


  static Future<ResultModel> sendMessageRoom(String userId, String content,String type, String roomId) async {
    final response = await http.post(
      Uri.parse("${baseUrl}users/sendMessageRoom"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "senderId": userId,
        "content": content,
        "roomId": roomId,
        "type": type,
      }),
    );

    return resultModelFromJson(response.body);
  }

  static Future<ResultModel> AddProductService(String userId,String title, String description,List<String> images, String? type) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/createProduct"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
          'title': title,
          'description': description,
          'images': images,
          'type': type
        }));

    return resultModelFromJson(response.body);
  }

  static Future<ProductServiceModel> FetchUserProductService(String userId) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/getAllUserPrductService"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
        }));
    return productServiceModelFromJson(response.body);
  }

  static Future<UserStoryModel> FetchUserStory(String userId) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/getUserStory"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
        }));

    return userStoryModelFromJson(response.body);
  }

  static Future<UserPlanModel> FetchUserPlan(String userId) async
  {

    final response = await http.post(Uri.parse("${baseUrl}users/getUserPlan"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          "userId": userId,
        }));

    return userPlanModelFromJson(response.body);
  }

}