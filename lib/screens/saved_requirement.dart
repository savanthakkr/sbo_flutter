import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/requirment_model.dart' as rmodel;
import 'package:sbo/models/result_model.dart';
import 'package:sbo/models/user_list_model.dart';
import 'package:sbo/screens/personal_chat_screen.dart';
import 'package:sbo/screens/send_message_share.dart';
import 'package:sbo/utils/assets.dart';
import 'package:sbo/utils/connection_utils.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/custom_style.dart';
import 'package:sbo/utils/intentutils.dart';
import 'package:sbo/utils/prefs.dart';
import 'package:sbo/utils/size.dart';
import 'package:sbo/utils/ui_utils.dart';
import 'package:sbo/widgets/circular_progressbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/requirment_model.dart';


class SavedRequirementScreen extends StatefulWidget {
   SavedRequirementScreen({super.key});

  @override
  State<SavedRequirementScreen> createState() => _SavedRequirementScreenState();
}

class _SavedRequirementScreenState extends State<SavedRequirementScreen> {

  bool _isLoading = false;
  String? userId;
  List<AllRequirment> allReqirments = <AllRequirment>[];
  Map<int, int> feedCurrentMap = {};
  List<AllUser> allUserList = <AllUser>[];
  int current = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefs();
  }

  getPrefs() async{
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String? id = mPref.getString(Prefs.ID);

    setState(() {
      userId = id;
    });

    print("ID $userId");

    fetchAllRequirment();
    print(allReqirments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back_ios_rounded,color: CustomColor.primaryColor,),
        ),
        titleSpacing: 0,
        title: Text(
          "Saved Requirement ",
          style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.primaryColor,fontWeight: FontWeight.w500,fontSize: 16.0),
        ),
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
            feedWidget(),
          ],
        ),
      ),
    );
  }


  feedWidget(){
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context,index){
        return rawFeed(index);
      },
      itemCount: allReqirments.length,
    );
  }

  rawStory(int index){
    return Container(
      margin: const EdgeInsets.only(right: 15.0),
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
              child: Center(child: SvgPicture.asset(Assets.addImageIcon)),
            ),
          ),
        ],
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
                addHorizontalSpace(5.0),
                GestureDetector(
                    onTap: () {
                      saveRequirments(
                        allReqirments.elementAt(index).id.toString(),
                        allReqirments.elementAt(index).userId.toString(),
                      );
                    },
                    child: Icon(Icons.bookmark_rounded, color: CustomColor.secondaryColor)
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
                    autoPlay: true,
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
            UIUtils.bottomToast(context: context, text: resultModel.message, isError: false);

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
          final rmodel.RequirmentModel resultModel = await ApiManager.FetchSavedUserRequirment(userId!);

          if (resultModel.error == false) {
            setState(() {
              _isLoading = false;
              allReqirments = resultModel.allRequirment;
            });
            fetchAllUsers();
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
