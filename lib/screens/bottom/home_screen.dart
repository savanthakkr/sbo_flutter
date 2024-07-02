import 'dart:convert';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:device_info/device_info.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/requirment_model.dart' as rmodel;
import 'package:sbo/models/result_model.dart';
import 'package:sbo/models/user_list_model.dart';
import 'package:sbo/models/user_plan_model.dart';
import 'package:sbo/screens/notification_Screen.dart';
import 'package:sbo/screens/personal_chat_screen.dart';
import 'package:sbo/screens/profile_details_screen.dart';
import 'package:sbo/screens/show_image_screen.dart';
import 'package:sbo/utils/assets.dart';
import 'package:sbo/utils/connection_utils.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/custom_style.dart';
import 'package:sbo/utils/intentutils.dart';
import 'package:sbo/utils/prefs.dart';
import 'package:sbo/utils/send_notification.dart';
import 'package:sbo/utils/size.dart';
import 'package:sbo/utils/ui_utils.dart';
import 'package:sbo/widgets/circular_progressbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_story_model.dart';
import '../send_message_share.dart';
import 'dart:io' as Io;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool _isLoading = false;
  String? userId,userType;
  List<rmodel.AllRequirment> allReqirments = <rmodel.AllRequirment>[];
  Map<int, int> feedCurrentMap = {};
  int current = 0;
  List<AllUser> allUserList = <AllUser>[];
  List<UserStory> userStoryList = <UserStory>[];
  String? profileImgurl,planValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefs();
  }

  getPrefs() async{
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String? id = mPref.getString(Prefs.ID);
    String? type = mPref.getString(Prefs.TYPE);

    setState(() {
      userId = id;
      userType = type;
    });

    print("ID $userId");

    fetchUserPlan();
    fetchAllRequirment();
    fetchAllStory();
    print(allReqirments);
    fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(Assets.appLogo,height: 24.0,width: 24.0,color: CustomColor.primaryColor,),
        ),
        titleSpacing: 0,
        title: Text(
          "sbo GROUP",
          style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.primaryColor,fontWeight: FontWeight.w500,fontSize: 16.0),
        ),
        actions: [
          GestureDetector(
              onTap: (){
                IntentUtils.fireIntentwithAnimations(context, NotificationScreen(), false);
              },
              child: SvgPicture.asset(Assets.tagIcon,height: 24.0,width: 24.0,)),
          addHorizontalSpace(15.0),
        ],
      ),
      body: _isLoading ? CircularProgressBar() : _bodyWidget(),
    );
  }

  _bodyWidget(){
    return Container(
      margin: const EdgeInsets.only(top: 20.0,bottom: 20.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            storyWidget(),
            userStoryList.isNotEmpty ? Divider(
              color: Colors.grey.shade200,
              thickness: 2,
            ) : userType == "Personal" ? Container() : Divider(
              color: Colors.grey.shade200,
              thickness: 2,
            ),
            feedWidget(),
          ],
        ),
      ),
    );
  }

  void fetchAllUsers() {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
          allUserList.clear();
        });
        try {
          final UserListModel resultModel = await ApiManager.FetchAllUsers(userId!);

          if (resultModel.error == false) {
            setState(() {
              _isLoading = false;
              allUserList = resultModel.allUsers; // Filter the users after fetching them
            });
          } else {
            setState(() {
              _isLoading = false;
            });
            UIUtils.bottomToast(context: context, text: resultModel.message, isError: true);
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          UIUtils.bottomToast(context: context, text: e.toString(), isError: true);
        }
      } else {
        // No-Internet Case
        UIUtils.bottomToast(
            context: context,
            text: "Please check your internet connection",
            isError: true);
      }
    });
  }

  void fetchUserPlan() {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
        });
        try {
          final UserPlanModel resultModel = await ApiManager.FetchUserPlan(userId!);

          if (resultModel.error == false) {
            setState(() {
              _isLoading = false;
              if(resultModel.userPlan.isNotEmpty){
                if(resultModel.userPlan.first.subscriptionPlan.isNotEmpty){
                  planValue = resultModel.userPlan.first.subscriptionPlan;
                }

                if(resultModel.userPlan.first.status.isNotEmpty){
                  if(resultModel.userPlan.first.status == "1"){
                    openVerificationPopup();
                  }
                }
              }
            });
          } else {
            setState(() {
              _isLoading = false;
            });
            UIUtils.bottomToast(context: context, text: resultModel.message, isError: true);
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          UIUtils.bottomToast(context: context, text: e.toString(), isError: true);
        }
      } else {
        // No-Internet Case
        UIUtils.bottomToast(
            context: context,
            text: "Please check your internet connection",
            isError: true);
      }
    });
  }

  Widget storyWidget() {
    return Container(
      height: 100.0,
      margin: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: Row(
        children: [
          userType == "Personal" ? Container() : Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: (){
                if(planValue == null || planValue!.isEmpty || planValue == ""){
                  UIUtils.bottomToast(context: context, text: "You have not any active plan", isError: true);
                } else {
                  if (planValue == "Silver") {
                    openPaymentPopup();
                  } else {
                    checkPermission(true);
                  }
                }
              },
              child: Column(
                children: [
                  DottedBorder(
                    borderType: BorderType.Circle,
                    dashPattern: const [5, 7],
                    color: CustomColor.primaryColor,
                    strokeWidth: 1.5,

                    child: Container(
                      height: 75.0,
                      width: 75.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: profileImgurl == null || profileImgurl!.isEmpty ? Center(child: SvgPicture.asset(Assets.addImageIcon)) : ClipRRect(
                          borderRadius: BorderRadius.circular(65),
                          child: Image.memory(base64Decode(profileImgurl!,),fit: BoxFit.cover,)),
                      // child: Center(child: SvgPicture.asset(Assets.addImageIcon)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          userType == "Personal" ? Container() : addHorizontalSpace(15.0),
          Expanded(
            child: userStoryList.isNotEmpty ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(userStoryList.length, (index) {
                  return rawStory(index);
                }),
              ),
            ) : Container(),
          ),
        ],
      ),
    );
  }

  openVerificationPopup() async {
    final _formKey = GlobalKey<FormState>();

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: StatefulBuilder(
              builder: (context, setAlert) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  content: Container(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "Verification",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16.0,fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0,),
                          Text(
                            "Your account is under verification.",
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14.0,fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 30.0,),
                        ],
                      ),
                    ),
                  ),
                );
              }
          ),
        )
    );
  }

  openPaymentPopup() async {
    final _formKey = GlobalKey<FormState>();

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(
            builder: (context, setAlert) {
              return AlertDialog(
                backgroundColor: Colors.white,
                content: Container(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Pay Amount",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16.0,fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                Navigator.of(context).pop();
                              },
                              child: Icon(Icons.close_rounded,color: CustomColor.primaryColor,),
                            )
                          ],
                        ),
                        SizedBox(height: 20.0,),
                        Text(
                          "Your plan is not a premium plan for uploading story please pay 50 Rs then you have upload your story.",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14.0,fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 30.0,),
                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).pop();
                            checkPermission(true);
                          },
                          child: Container(
                            height: 55.0,
                            decoration: BoxDecoration(
                              color: CustomColor.primaryColor,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Center(
                              child: Text(
                                "Pay",
                                style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w800,fontSize: 14.0,color: CustomColor.whiteColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        )
    );
  }

  addSchoolPopup() async {
    final _formKey = GlobalKey<FormState>();
    String? _radioValue;

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(
            builder: (context, setAlert) {
              return AlertDialog(
                backgroundColor: Colors.white,
                content: Container(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Select Time",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16.0,fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                Navigator.of(context).pop();
                              },
                              child: Icon(Icons.close_rounded,color: CustomColor.primaryColor,),
                            )
                          ],
                        ),

                        SizedBox(height: 20.0,),
                        Row(
                          children: [
                            Row(
                              children: [
                                Radio(
                                  value: '24',
                                  groupValue: _radioValue,
                                  onChanged: (value) {
                                    setAlert(() {
                                      _radioValue = value as String;
                                      print(_radioValue);
                                    });
                                  },
                                  activeColor: CustomColor.primaryColor,
                                ),
                                Text('24 Hours'),
                              ],
                            ),
                            SizedBox(width: 20), // add some space between the two radio buttons
                            Row(
                              children: [
                                Radio(
                                  value: '48',
                                  groupValue: _radioValue,
                                  onChanged: (value) {
                                    setAlert(() {
                                      _radioValue = value as String;
                                      print(_radioValue);
                                    });
                                  },

                                  activeColor: CustomColor.primaryColor,
                                ),
                                Text('48 Hours'),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(

                          onTap: (){
                            Navigator.of(context).pop();
                            createStoryProfile(_radioValue!);
                          },
                          child: Container(
                            height: 55.0,
                            decoration: BoxDecoration(
                              color: CustomColor.primaryColor,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Center(
                              child: Text(
                                "Add",

                                style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w800,fontSize: 14.0,color: CustomColor.whiteColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        )
    );
  }


  void createStoryProfile(String time) {
    ConnectionUtils.checkConnection().then((intenet) async {
      if (intenet) {
        setState(() {
          _isLoading = true;
        });
        try{
          final ResultModel resultModel = await ApiManager.createStory(
              userId!,
            profileImgurl!,
            time,

          );

          if(resultModel.error == false) {
            setState(() {
              _isLoading = false;
            });
            UIUtils.bottomToast(context: context, text: resultModel.message, isError: false);
          } else{
            setState(() {
              _isLoading = false;
            });
            UIUtils.bottomToast(context: context, text: resultModel.message, isError: true);
          }
        }
        on Exception catch(_,e){
          setState(() {
            _isLoading = false;
          });
          UIUtils.bottomToast(context: context, text: e.toString(), isError: true);
        }
      }
      else {
        // No-Internet Case
        UIUtils.bottomToast(context: context, text: "Please check your internet connection", isError: true);
      }
    });
  }


  checkPermission(bool isProfile) async{
    if (Io.Platform.isAndroid) {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      debugPrint('MY_SDK : ${androidInfo.version.sdkInt}');
      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.photos.request();
        // final status2 = await Permission.camera.request();
        if (status == PermissionStatus.granted) {
          print('Permission granted.');
          openProfileImage(isProfile);
        } else if (status == PermissionStatus.denied) {
          print(
              'Permission denied. Show a dialog and again ask for the permission');
          await Permission.storage.shouldShowRequestRationale;
        }
      }
      else{
        final status = await Permission.storage.request();
        // final status2 = await Permission.camera.request();
        if (status == PermissionStatus.granted) {
          print('Permission granted.');
          openProfileImage(isProfile);
        } else if (status == PermissionStatus.denied) {
          print(
              'Permission denied. Show a dialog and again ask for the permission');
          await Permission.storage.shouldShowRequestRationale;
        }
      }
    }
  }

  Widget addHorizontalSpace(double width) {
    return SizedBox(width: width);
  }

  openProfileImage(bool isProfile) async {
    setState(() {
      if(isProfile) {
        profileImgurl = "";
      }
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image,allowMultiple: false);

    if (result != null) {
      setState(() {
        String fileName = result.files.first.name;
        print("fileName ${fileName}");

        String? filePath = result.files.first.path;
        final bytes = Io.File(filePath!).readAsBytesSync();
        if(isProfile) {
          profileImgurl = base64Encode(bytes);
          createStoryProfile("24");
        }
      });
    }
    setState(() {});
  }


  // addHorizontalSpace(15.0),
  // ListView.builder(
  //   shrinkWrap: true,
  //   physics: NeverScrollableScrollPhysics(),
  //   scrollDirection: Axis.horizontal,
  //   itemBuilder: (context,index){
  //     return rawStory(index);
  //   },
  //   itemCount: 1,
  // )

  feedWidget(){
    return allReqirments.isNotEmpty ? ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context,index){
        return rawFeed(index);
      },
      itemCount: allReqirments.length,
    )  : Center(
      child: Text(
        "No feed found",
        style: CustomStyle.inputTextStyle.copyWith(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.black),
      ),
    );
  }

  rawStory(int index){

    Uint8List bytes = base64.decode(userStoryList.elementAt(index).photo);

    return GestureDetector(

      onTap: (){

        Uint8List mybytes = base64.decode(userStoryList.elementAt(index).photo);

        IntentUtils.fireIntentwithAnimations(context, ShowImageScreen(bytes: mybytes), false);

      },

      child: Container(
        margin: const EdgeInsets.only(right: 15.0),
        child: Column(
          children: [
            SizedBox(
              height: 75,
              width: 75,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(75),
                child: Image.memory(bytes,fit: BoxFit.fill,),
              ),
            ),
          ],
        ),
      ),
    );
  }

  rawFeed(int index){
    dynamic bytes;
    if(allReqirments.elementAt(index).profile != null && allReqirments.elementAt(index).profile.isNotEmpty){
      bytes = base64.decode(allReqirments.elementAt(index).profile);
    } else {
      bytes = null;
    }
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 15.0,right: 15.0),
            child: Row(
              children: [
                Container(
                  height: 50.0,
                  width: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: bytes != null ? Image.memory(bytes).image : Image.asset(Assets.appLogoMain,color: CustomColor.primaryColor,).image,
                    ),
                  ),
                ),
                addHorizontalSpace(10.0),
                Expanded(
                  child: Text(
                    allUserList.elementAt(index).name,
                    style: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
                  ),
                ),
                 GestureDetector(
                     onTap: () {
                       String type = allUserList.elementAt(index).type;
                       String name = allUserList.elementAt(index).name;
                       String id = allUserList.elementAt(index).id.toString();
                       String fStatus = allUserList.elementAt(index).fStatus;
                       String fuserId = allUserList.elementAt(index).reqId;


                       print(id);
                       print("object");

                       IntentUtils.fireIntentwithAnimations(
                         context,
                         ProfileDetailsScreen(id: id, name: name, type: type, fStatus: fStatus, fuserId: fuserId),
                         false,
                       );
                     },
                     child: SvgPicture.asset(Assets.connectPeopleIcon,color: CustomColor.secondaryColor,
                     )
                 ),
                addHorizontalSpace(5.0),
                GestureDetector(
                    onTap: () {
                      saveRequirments(
                        allReqirments.elementAt(index).id.toString(),
                        allReqirments.elementAt(index).userId.toString(),
                      );
                    },
                    child: Icon(allReqirments.elementAt(index).isSaved == false ? Icons.bookmark_border_rounded : Icons.bookmark_rounded, color: CustomColor.secondaryColor)
                  // child: Icon(Icons.bookmark_rounded, Icons.allReqirments.elementAt(index).isSaved == false ? CustomColor.primaryColor : CustomColor.secondaryColor),
                ),

              ],
            ),
          ),
          addVerticalSpace(30.0),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(15.0),
            decoration: const BoxDecoration(
              color: CustomColor.lightsecondaryColor,
            ),
            child: Text(
              allReqirments.elementAt(index).title,
              style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.secondaryColor,fontSize: 15.0,fontWeight: FontWeight.w600),
            ),
          ),
          addVerticalSpace(20.0),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 15.0,right: 15.0),
            child: Text(
              allReqirments.elementAt(index).description,
              style: CustomStyle.inputTextStyle.copyWith(fontSize: 15.0,fontWeight: FontWeight.w400),
            ),
          ),
          addVerticalSpace(20.0),
          allReqirments.elementAt(index).images.isNotEmpty ? Container(
              child: CarouselSlider(
                options: CarouselOptions(
                    aspectRatio: 2.0,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                    autoPlay: false,
                    onPageChanged: (index,reason){
                      setState(() {
                        current = index;
                      });
                    }
                ),
                items: allReqirments.elementAt(index).images.map((e) => Container(
                  height: 300,
                  child: Image.memory(base64Decode(e.url)),
                )).toList(),
              )
          ) : Container(),
          allReqirments.elementAt(index).images.isNotEmpty ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: allReqirments.elementAt(index).images.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => setState(() {
                  current = entry.key;
                }),
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: current == entry.key
                        ? CustomColor.secondaryColor
                        : CustomColor.lightsecondaryColor,
                  ),
                ),
              );
            }).toList(),
          ) : Container(),
          allReqirments.elementAt(index).images.isNotEmpty ? addVerticalSpace(20.0) : Container(),
          Container(
            margin: const EdgeInsets.only(left: 15.0,right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(Assets.messageIcon,color: CustomColor.blackColor,),
                    addHorizontalSpace(10.0),
                    GestureDetector(
                      onTap: (){

                        String type = allReqirments.elementAt(index).userType;
                        String name = allReqirments.elementAt(index).userName;
                        String id = allReqirments.elementAt(index).userId;

                        print(type);
                        print(name);
                        print(id);

                        IntentUtils.fireIntentwithAnimations(context, ChatScreenPersonal(id: id, name: name,type: type,), false);

                      },
                      child: Text(
                        "Chat to show Interest",
                        style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w700,fontSize: 15.0,color: CustomColor.blackColor),
                      ),
                    ),
                  ],
                ),

                GestureDetector(
                  onTap: (){

                    String id = allReqirments.elementAt(index).id.toString();
                    IntentUtils.fireIntentwithAnimations(context, SendMessageShare(id: id ), false);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.share_rounded,color: CustomColor.blackColor,),
                      addHorizontalSpace(10.0),
                      Text(
                        "Share",
                        style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w700,fontSize: 15.0,color: CustomColor.blackColor),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          addVerticalSpace(15.0),
          Divider(
            color: Colors.grey.shade200,
            thickness: 2,
          ),
        ],
      ),
    );
  }

  void fetchAllStory() {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
          userStoryList.clear();
        });
        try {
          final UserStoryModel resultModel = await ApiManager.FetchUserStory(userId!);
          if (resultModel.error == false) {
            setState(() {
              _isLoading = false;
              userStoryList = resultModel.userStory;
            });
            print("Data ${userStoryList.length} ${resultModel.userStory.length}");
          } else {
            setState(() {
              _isLoading = false;
            });
            UIUtils.bottomToast(context: context, text: resultModel.message, isError: true);
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          UIUtils.bottomToast(context: context, text: e.toString(), isError: true);
        }
      } else {
        // No-Internet Case
        UIUtils.bottomToast(
            context: context,
            text: "Please check your internet connection",
            isError: true);
      }
    });
  }


  void saveRequirments(String id, String rUserId) {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
        });
        try {
          print("Saving requirement: $id for user: $rUserId");

          // Simulate an API call with delay
          final ResultModel resultModel = await ApiManager.saveRequirements(
              userId!,
              id,
              rUserId
          );

          if (resultModel.error == false) {
            setState(() {
              _isLoading = false;
            });
            print("Requirement saved successfully");
            UIUtils.bottomToast(context: context, text: resultModel.message, isError: false);
            SendNotification.getToken("Requirement Save", "Your Requirement save by your connect", rUserId, "Save");
            fetchAllRequirment();
          } else {
            setState(() {
              _isLoading = false;
            });
            print("Error saving requirement: ${resultModel.message}");
            UIUtils.bottomToast(context: context, text: resultModel.message, isError: true);
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          print("Exception occurred: $e");
          UIUtils.bottomToast(context: context, text: e.toString(), isError: true);
        }
      } else {
        // No-Internet Case
        UIUtils.bottomToast(
            context: context,
            text: "Please check your internet connection",
            isError: true);
      }
    });
  }

  void fetchAllRequirment() {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
          allReqirments.clear();
        });
        try {
          final rmodel.RequirmentModel resultModel = await ApiManager.FetchFollowUserRequirment(userId!);

          if (resultModel.error == false) {
            setState(() {
              _isLoading = false;
              allReqirments = resultModel.allRequirment;
            });

            print("Data ${allReqirments.length} ${resultModel.allRequirment.length}");

          } else {
            setState(() {
              _isLoading = false;
            });
            UIUtils.bottomToast(context: context, text: resultModel.message, isError: true);
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          UIUtils.bottomToast(context: context, text: e.toString(), isError: true);
        }
      } else {
        // No-Internet Case
        UIUtils.bottomToast(
            context: context,
            text: "Please check your internet connection",
            isError: true);
      }
    });
  }

}
