import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/chat_user_model.dart';
import 'package:sbo/models/group_chat_user_model.dart';
import 'package:sbo/models/result_model.dart';
import 'package:sbo/screens/create_group_screen.dart';
import 'package:sbo/screens/personal_chat_screen.dart';
import 'package:sbo/screens/room_chat_screen.dart';
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

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  bool _isLoading = false;
  String? userId;
  DateTime? lsatmessagetime;
  List<ChatUser> chatUsers = <ChatUser>[];
  List<RoomDetail> groupchatUsers = <RoomDetail>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefs();
  }

  getPrefs() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String? id = mPref.getString(Prefs.ID);

    setState(() {
      userId = id;
    });

    chatUser();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 0,
        leading: Container(),
        title: Text(
          "Chat",
          style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.primaryColor,fontWeight: FontWeight.w700,fontSize: 18.0),
        ),
        actions: [
          GestureDetector(
            onTap: (){
              // IntentUtils.fireIntentwithAnimations(context, CreateGroupScreen(), false);

              Navigator.of(context).push(PageRouteBuilder(

                // transitionDuration: Duration(seconds: 2),
                pageBuilder: (_, __, ___) {
                  return CreateGroupScreen();
                },
              )
              ).then((onValue){
                chatUser();
              });
            },
            child: Row(
              children: [
                SvgPicture.asset(Assets.addImageIcon),
                addHorizontalSpace(5.0),
                Text(
                  "Create Group",
                  style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.primaryColor,fontSize: 14.0,fontWeight: FontWeight.w600),
                ),
                addHorizontalSpace(10.0),
              ],
            ),
          )
        ],
      ),
      body: _isLoading ? CircularProgressBar() : _bodyWidget(),
    );
  }

  _bodyWidget(){
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 6,
                child: TabBar(
                  // splashBorderRadius: BorderRadius.circular(20),
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: const EdgeInsets.all(16),
                  tabAlignment: TabAlignment.fill,
                  dividerHeight: 0,
                  // indicator: BoxDecoration(color: CustomColor.secondaryColor, borderRadius: BorderRadius.circular(9.0)),
                  labelStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: CustomColor.secondaryColor,fontWeight: FontWeight.w600,fontSize: 14.0),
                  unselectedLabelColor: CustomColor.blackColor,
                  indicatorColor: Colors.transparent,
                  unselectedLabelStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: CustomColor.blackColor,fontWeight: FontWeight.w600,fontSize: 14.0),
                  labelPadding: const EdgeInsets.symmetric(vertical: 4),
                  tabs: const [
                    Text("People"),
                    Text("Groups"),
                  ],
                ),
              ),
              Expanded(flex:4, child: Container())
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                userChatWidget(),
                groupChatWidget()
              ],
            ),
          )
        ],
      ),
    );
  }



  userChatWidget(){
    chatUsers.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return chatUsers.isNotEmpty ? ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context,index){
        return rawChat(index);
      },
      itemCount: chatUsers.length,
      shrinkWrap: true,
    ) : Center(
      child: Text(
        "No chat user found",
        style: CustomStyle.inputTextStyle.copyWith(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.black),
      ),
    );
  }

  rawChat(int index) {

    dynamic bytes;
    if(chatUsers.elementAt(index).image!.isNotEmpty){
      bytes = base64.decode(chatUsers.elementAt(index).image!);
    } else {
      bytes = null;
    }

    return Container(
      margin: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 15.0, right: 15.0),
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {

          String type = chatUsers.elementAt(index).type;
          String name = chatUsers.elementAt(index).name;
          String id = chatUsers.elementAt(index).id.toString();

          print(type);
          print(name);
          print(id);
          _sendMessage(id);

          Navigator.of(context).push(PageRouteBuilder(

            // transitionDuration: Duration(seconds: 2),
            pageBuilder: (_, __, ___) {
              return ChatScreenPersonal(id: id, name: name, type: type);
            },
          )
          ).then((onValue){
            chatUser();
          });

        },
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
            addHorizontalSpace(15.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatUsers.elementAt(index).name,
                    style: CustomStyle.inputTextStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.0,
                    ),
                  ),
                  Text(
                    chatUsers.elementAt(index).type,
                    style: CustomStyle.inputTextStyle.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.0,
                      color: CustomColor.greyColor,
                    ),
                  ),
                ],
              ),
            ),
            addHorizontalSpace(10.0),
            Row(
              children: [
                Container(
                  height: 25.0,
                  width: 25.0,
                  decoration: BoxDecoration(
                    color: CustomColor.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      chatUsers.elementAt(index).unseenMessagesCount.toString(),
                      style: CustomStyle.inputTextStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),
                addHorizontalSpace(10.0),
                SvgPicture.asset(
                  Assets.messageIcon,
                  color: CustomColor.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  groupChatWidget(){
    // groupchatUsers.sort((a, b) => b.room.lastMessageTime.compareTo(a.room.lastMessageTime));
    DateTime defaultDateTime = DateTime.fromMillisecondsSinceEpoch(0);

    groupchatUsers.sort((a, b) {
      DateTime aTime = a.room.lastMessageTime ?? defaultDateTime;
      DateTime bTime = b.room.lastMessageTime ?? defaultDateTime;
      return bTime.compareTo(aTime);
    });
    return groupchatUsers.isNotEmpty ? ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context,index){
        return rawGroupChat(index);
      },
      itemCount: groupchatUsers.length,
      shrinkWrap: true,
    ) : Center(
      child: Text(
        "No group chat found",
        style: CustomStyle.inputTextStyle.copyWith(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.black),
      ),
    );
  }

  rawGroupChat(int index){
    return Container(
      margin: const EdgeInsets.only(top: 5.0,bottom: 5.0,left: 15.0,right: 15.0),
      padding:const  EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: (){


          String roomId = groupchatUsers.elementAt(index).room.id.toString();

          Navigator.of(context).push(PageRouteBuilder(

            // transitionDuration: Duration(seconds: 2),
            pageBuilder: (_, __, ___) {
              return ChatScreenRoom(roomId: roomId);
            },
          )
          ).then((onValue){
            GroupchatUser();
          });

          // IntentUtils.fireIntentwithAnimations(context, ChatScreenRoom(roomId: roomId), false);
        },
        child: Row(
          children: [
            Container(
              height: 50.0,
              width: 50.0,
              decoration: BoxDecoration(
                color: CustomColor.lightButtonBg,
                  shape: BoxShape.circle,
              ),
              child: Center(child: SvgPicture.asset(Assets.groupIcon)),
            ),
            addHorizontalSpace(15.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupchatUsers.elementAt(index).room.gName.toString() == null ? "Group ${groupchatUsers.elementAt(index).room.id.toString()}" : groupchatUsers.elementAt(index).room.gName.toString(),
                    style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w700,fontSize: 15.0),
                  ),
                  Text(
                    groupchatUsers.elementAt(index).participants.length.toString()+" Members",
                    style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w400,fontSize: 12.0,color: CustomColor.greyColor),
                  )
                ],
              ),
            ),
            addHorizontalSpace(10.0),
            Row(
              children: [
                Container(
                  height: 25.0,
                  width: 25.0,
                  decoration: BoxDecoration(
                    color: CustomColor.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text("0",
                      // groupchatUsers.elementAt(index).room.unseenMessagesCount.toString(),
                      style: CustomStyle.inputTextStyle.copyWith(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 12.0),
                    ),
                  ),
                ),
                addHorizontalSpace(10.0),
                SvgPicture.asset(Assets.messageIcon,color: CustomColor.primaryColor,)
              ],
            )
          ],
        ),
      ),
    );
  }

  void chatUser() {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
          chatUsers.clear();
        });
        try {
          final ChatUserModel resultModel = await ApiManager.fetchChatUser(
            userId!,
          );
          if (resultModel.error == false) {
            setState(() {
              chatUsers.addAll(resultModel.chatUser);
              _isLoading = false;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
            // UIUtils.bottomToast(context: context, text: resultModel.message, isError: true);
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          // UIUtils.bottomToast(context: context, text: e.toString(), isError: true);
        }
        GroupchatUser();
      } else {
        // No-Internet Case
        UIUtils.bottomToast(
            context: context,
            text: "Please check your internet connection",
            isError: true);
      }
    });
  }

  void _sendMessage(String id) {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = false;
        });
        try {
          final ResultModel resultModel = await ApiManager.sendMessageAsSeen(
            userId!,
            id,
          );

          if (!resultModel.error) {
            setState(() {
              _isLoading = false;
              // SendNotification.getToken("New Message", "You have a New Message", id, "User");
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
        UIUtils.bottomToast(
          context: context,
          text: "Please check your internet connection",
          isError: true,
        );
      }
    });
  }

  void GroupchatUser() {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
          groupchatUsers.clear();
        });
        try {
          final GroupChatUserModel resultModel = await ApiManager.FetchGroupChats(
            userId!,
          );

          if (resultModel.error == false) {
            setState(() {
              _isLoading = false;
              groupchatUsers.addAll(resultModel.roomDetails);
            });
          } else {
            setState(() {
              _isLoading = false;
            });
            // UIUtils.bottomToast(context: context, text: resultModel.message, isError: true);
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
