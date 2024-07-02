import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/result_model.dart';
import 'package:sbo/screens/bottom/account_screen.dart';
import 'package:sbo/screens/bottom/chat_screen.dart';
import 'package:sbo/screens/bottom/home_screen.dart';
import 'package:sbo/screens/bottom/requirment_screen.dart';
import 'package:sbo/screens/bottom/serach_screen.dart';
import 'package:sbo/utils/assets.dart';
import 'package:sbo/utils/connection_utils.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/prefs.dart';
import 'package:sbo/utils/ui_utils.dart';

class UserBottomScreen extends StatefulWidget {

  int index = 0;
  UserBottomScreen({super.key,required this.index});

  @override
  State<UserBottomScreen> createState() => _UserBottomScreenState();
}

class _UserBottomScreenState extends State<UserBottomScreen> {

  var scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  List listofpage = [
    HomeScreen(),
    SearchScreen(),
    RequirementScreen(),
    ChatScreen(),
    AccountScreen()
  ];
  bool _isLoading = false;
  String? strToken;
  String? userId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefs();
    setState(() {
      _currentIndex = widget.index;
    });
  }

  getPrefs() async{
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String? id = mPref.getString(Prefs.ID);

    setState(() {
      userId = id;
    });

    getFirebaseToken();
    checkNotificationPermission();
  }


  Future<bool> _onBackPressed() async {
    if(_currentIndex == 0){
      SystemNavigator.pop();
    } else {
      setState(() {
        _currentIndex = 0;
      });
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: scaffoldKey,
        bottomNavigationBar: bottomWidget(),
        body: _isLoading ? Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              color: CustomColor.primaryColor,
            )
        ) : listofpage[_currentIndex],
      ),
    );
  }

  bottomWidget(){
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.black12,
            width: 2,
          ),
        ),
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: CustomColor.whiteColor,
        unselectedItemColor: CustomColor.primaryColor,
        selectedItemColor: CustomColor.primaryColor,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (int index){
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(Assets.homeUnfillIcon,height: 25,color: CustomColor.primaryColor,),
            label: '',
            activeIcon: SvgPicture.asset(Assets.homeFillIcon,height: 25,color: CustomColor.primaryColor,),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(Assets.searchUnfillIcon,height: 25,color: CustomColor.primaryColor),
            label: '',
            activeIcon: SvgPicture.asset(Assets.searchFillIcon,height: 25,color: CustomColor.primaryColor,),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(Assets.addUnfillIcon,height: 25,color: CustomColor.primaryColor),
            label: '',
            activeIcon: SvgPicture.asset(Assets.addFillIcon,height: 25,color: CustomColor.primaryColor,),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(Assets.chatUnfillIcon,height: 25,color: CustomColor.primaryColor),
            label: '',
            activeIcon: SvgPicture.asset(Assets.chatFillIcon,height: 25,color: CustomColor.primaryColor,),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(Assets.userUnfillIcon,height: 25,color: CustomColor.primaryColor),
            label: '',
            activeIcon: SvgPicture.asset(Assets.userFillIcon,height: 25,color: CustomColor.primaryColor,),
          ),
        ],
      ),
    );
  }
  checkNotificationPermission() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    if(Platform.isAndroid){
      AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      if(androidDeviceInfo.version.sdkInt >= 33){
        final notification = await Permission.notification.request();
        if(notification == PermissionStatus.granted){
          print("Permission Granted");
        } else if(notification == PermissionStatus.denied){
          print("Permission denied. Show a dialog and again ask for the permission");
          await [Permission.notification].request();
        }
      }
    }
  }

  getFirebaseToken(){
    FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        strToken = token.toString();
        print(strToken);
      });

      UpdateToken(strToken!);
    });
  }

  void UpdateToken(String token) {
    ConnectionUtils.checkConnection().then((intenet) async {
      if (intenet) {
        setState(() {
          _isLoading = true;
        });
        try{

          final ResultModel resultModel = await ApiManager.UpdateUserToken(
              token,userId
          );

          if(resultModel.error == false) {
            setState(() {
              _isLoading = false;
            });

          } else{
            setState(() {
              _isLoading = false;
            });
          }
        }
        on Exception catch(_,e){
          setState(() {
            _isLoading = false;
          });
        }
      }
      else {
        // No-Internet Case
        UIUtils.bottomToast(context: context, text: "Please check your internet connection", isError: true);
      }
    });
  }
}
