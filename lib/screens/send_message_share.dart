import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/chat_user_model.dart';
import 'package:sbo/models/result_model.dart';
import 'package:sbo/utils/assets.dart';
import 'package:sbo/utils/connection_utils.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/custom_style.dart';
import 'package:sbo/utils/dimensions.dart';
import 'package:sbo/utils/prefs.dart';
import 'package:sbo/utils/send_notification.dart';
import 'package:sbo/utils/size.dart';
import 'package:sbo/utils/ui_utils.dart';
import 'package:sbo/widgets/circular_progressbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendMessageShare extends StatefulWidget {

  final String id;

  SendMessageShare({Key? key, required this.id}) : super(key: key);

  @override
  State<SendMessageShare> createState() => _SendMessageShareState();
}

class _SendMessageShareState extends State<SendMessageShare> {

  bool _isLoading = false;
  String? userId;
  List<ChatUser> chatUsers = <ChatUser>[];

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
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
        ),
        title: Text(
          "Connections",
          style: CustomStyle.inputTextStyle.copyWith(
              color: CustomColor.blackColor, fontWeight: FontWeight.w600, fontSize: 16.0),
        ),
      ),
      body: _isLoading ? CircularProgressBar() : Column(
        children: [
          Expanded(child: _bodyWidget()),
          addVerticalSpace(Dimensions.marginSize),
          GestureDetector(
            onTap: () {
              List<dynamic> _selectedUser = <dynamic>[];

              // Collect selected user IDs
              for (int i = 0; i < chatUsers.length; i++) {
                if (chatUsers.elementAt(i).isSelect ?? false) {
                  setState(() {
                    _selectedUser.add(chatUsers.elementAt(i).id);
                  });
                }
              }

              if (_selectedUser.isNotEmpty) {
                // Send each selected user's ID individually
                for (var userId in _selectedUser) {
                  sendMessageShare(userId.toString());
                }
                Navigator.of(context).pop();
              } else {
                UIUtils.bottomToast(
                    context: context,
                    text: "Please select at least one connection",
                    isError: true
                );
              }
            },
            child: Container(
              height: 55.0,
              margin: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: CustomColor.primaryColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Text(
                  "Send",
                  style: CustomStyle.inputTextStyle.copyWith(
                      fontWeight: FontWeight.w800, fontSize: 14.0, color: CustomColor.whiteColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  _bodyWidget(){
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

  rawChat(int index){
    return Container(
      margin: const EdgeInsets.only(top: 5.0,bottom: 5.0,left: 15.0,right: 15.0),
      padding:const  EdgeInsets.all(5.0),
      child: Row(
        children: [
          Container(
            height: 50.0,
            width: 50.0,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.asset(Assets.storyImageIcon).image)
            ),
          ),
          addHorizontalSpace(15.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chatUsers.elementAt(index).name,
                  style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w700,fontSize: 15.0),
                ),
                Text(
                  chatUsers.elementAt(index).type,
                  style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w400,fontSize: 12.0,color: CustomColor.greyColor),
                )
              ],
            ),
          ),
          addHorizontalSpace(10.0),
          Checkbox(
            value: chatUsers.elementAt(index).isSelect ?? false,
            onChanged: (value){
              setState(() {
                chatUsers.elementAt(index).isSelect = value;
              });
            },
            activeColor: CustomColor.primaryColor,
            shape: CircleBorder(),
          )
        ],
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
              _isLoading = false;
              chatUsers.addAll(resultModel.chatUser);
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


  void sendMessageShare(String id) {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = false;
        });
        try {
          final ResultModel resultModel = await ApiManager.sendMessage(
            userId!,
            widget.id,
            "requirement",
            id,
          );

          if (!resultModel.error) {
            setState(() {
              _isLoading = false;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
            UIUtils.bottomToast(context: context, text: resultModel.message, isError: true);
            SendNotification.getToken("Share Requirement", "Your connect share requirement with you", widget.id, "Share Requirement");
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

}
