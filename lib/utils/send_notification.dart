import 'dart:convert';

import 'package:flutter/services.dart' as service;
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/room_user_token.dart';
import 'package:sbo/models/user_token_model.dart';
import 'package:sbo/utils/connection_utils.dart';

class SendNotification {

  static String postUrl = "https://fcm.googleapis.com/v1/projects/sbonew-7a724/messages:send";

  static Future<void> sendNotification(String title,String body,String token,String uId,String flag) async {

    final String myresponse = await service.rootBundle.loadString('assets/json_files/firabse_service_account.json');
    final serviceAccount = json.decode(myresponse);
    // final serviceAccount = json.decode(await File('firabse_service_account.json').readAsString());
    final String accessToken = await _getAccessToken(serviceAccount);

    final data = {
      "message": {
        "token": token,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "userId": uId,
          "status": "done",
          "flag": flag,
        },
        "android": {
          "priority": "high"
        },
        "apns": {
          "headers": {
            "apns-priority": "10"
          },
          "payload": {
            "aps": {
              "alert": {
                "title": title,
                "body": body
              },
              "sound": "default"
            }
          }
        }
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    final response = await http.post(Uri.parse(postUrl),
      headers: headers,
      body: jsonEncode(data),
    );

    if(response.statusCode==200) {
      // CustomSnackBar.showCustomToast(message: "Notification send");
    } else {
      // CustomSnackBar.showCustomToast(message: "Notification not send");
    }
    print("Response ${response.statusCode} ${response.body}");
  }

  static getToken(String title,String body,String uId,String flag) {
    ConnectionUtils.checkConnection().then((intenet) async {
      if (intenet) {
        try{
          final UserTokenModel resultModel = await ApiManager.GetUserToken(uId);
          if(resultModel.error == false) {
            if(resultModel.userToken.isNotEmpty){
              sendNotification(title, body, resultModel.userToken.elementAt(0).token,uId,flag);
            }
          }
        } on Exception catch(_,e){

        }
      }
    });

    // saveNotification(uId,title,body,flag);
  }

  static getGroupToken(String title,String body,String uId,String flag) {
    ConnectionUtils.checkConnection().then((intenet) async {
      if (intenet) {
        try{
          final RoomUserTokenModel resultModel = await ApiManager.GetRoomUserToken(uId);
          if(resultModel.error == false) {
            if(resultModel.roomUserToken.isNotEmpty){
              for(int i=0;i<resultModel.roomUserToken.length;i++){
                sendNotification(title, body, resultModel.roomUserToken.elementAt(i).allUserToken.elementAt(0).token!,uId,flag);
              }
            }
          }
        } on Exception catch(_,e){

        }
      }
    });

    // saveNotification(uId,title,body,flag);
  }

  static Future<String> _getAccessToken(Map<String, dynamic> serviceAccount) async {
    final jwt = createJWT(serviceAccount);
    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': jwt,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      return responseBody['access_token'];
    } else {
      throw Exception('Failed to obtain access token: ${response.body}');
    }
  }

  static String createJWT(Map<String, dynamic> serviceAccount) {
    final iat = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final exp = iat + 3600; // 1 hour expiration

    final jwt = JWT(
      {
        'iss': serviceAccount['client_email'],
        'scope': 'https://www.googleapis.com/auth/firebase.messaging',
        'aud': 'https://oauth2.googleapis.com/token',
        'iat': iat,
        'exp': exp,
      },
    );

    final privateKey = serviceAccount['private_key'];
    final key = RSAPrivateKey(privateKey);

    return jwt.sign(key, algorithm: JWTAlgorithm.RS256);
  }

  // static saveNotification(String uId,String title,String body,String type){
  //   CollectionReference collectionReference = FirebaseFirestore.instance.collection("notifications");
  //   collectionReference.add({
  //     "userId": uId,
  //     "title": title,
  //     "body": body,
  //     "type": type,
  //     "created_at": DateTime.now(),
  //     "updated_at": DateTime.now(),
  //   }).then((value) {
  //
  //   }).onError((error, stackTrace) {
  //
  //   }).catchError((onError){
  //
  //   });
  // }
}