import 'dart:convert';

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

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {

  bool _isLoading = false;
  String? userId;
  TextEditingController _searchController = TextEditingController();
  List<ChatUser> chatUsers = <ChatUser>[];
  List<ChatUser> filteredUserList = <ChatUser>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefs();
    _searchController.addListener(() {
      filterUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredUserList = chatUsers.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.type.toLowerCase().contains(query) || user.category!.toLowerCase().contains(query);
      }).toList();
    });
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

              for (int i = 0; i < chatUsers.length; i++) {
                if (chatUsers.elementAt(i).isSelect ?? false) {
                  setState(() {
                    _selectedUser.add(chatUsers.elementAt(i).id);
                  });
                }
              }

              if (_selectedUser.isNotEmpty) {
                createGroup(_selectedUser);
              } else {
                UIUtils.bottomToast(
                    context: context, text: "Please select at least one connection", isError: true);
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
                  "Create",
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
    return Column(
      children: [
        _searchTextField(),
        addVerticalSpace(15.0),
        filteredUserList.isNotEmpty ? ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context,index){
            return rawChat(index);
          },
          itemCount: filteredUserList.length,
          shrinkWrap: true,
        ) : Center(
          child: Text(
            "No chat user found",
            style: CustomStyle.inputTextStyle.copyWith(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.black),
          ),
        ),
      ],
    );
  }

  _searchTextField() {
    return Container(
      margin: EdgeInsets.only(left: 20,right: 20),
      child: TextFormField(
        controller: _searchController,
        keyboardType: TextInputType.text,
        cursorColor: CustomColor.primaryColor,
        decoration: InputDecoration(
          border: UIUtils.searchinputborder,
          contentPadding: UIUtils.textinputPadding,
          errorBorder: UIUtils.searchinputborder,
          enabledBorder: UIUtils.searchinputborder,
          focusedBorder: UIUtils.searchinputborder,
          filled: true,
          fillColor: CustomColor.searchbgColor,
          counterText: '',
          hintText: "Find your network..",
          hintStyle: CustomStyle.hintTextStyle,
          suffixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SvgPicture.asset(
              Assets.searchUnfillIcon,
              color: CustomColor.blackColor,
            ),
          ),
        ),
        style: CustomStyle.inputTextStyle,
        textAlign: TextAlign.start,
      ),
    );
  }

  rawChat(int index){

    dynamic bytes;
    if(filteredUserList.elementAt(index).image != null && filteredUserList.elementAt(index).image!.isNotEmpty){
      bytes = base64.decode(filteredUserList.elementAt(index).image!);
    } else {
      bytes = null;
    }

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
                  image: bytes != null ? Image.memory(bytes).image : Image.asset(Assets.appLogoMain,color: CustomColor.primaryColor,).image,
                )
            ),
          ),
          addHorizontalSpace(15.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filteredUserList.elementAt(index).name,
                  style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w700,fontSize: 15.0),
                ),
                Text(
                  filteredUserList.elementAt(index).type,
                  style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w400,fontSize: 12.0,color: CustomColor.greyColor),
                )
              ],
            ),
          ),
          addHorizontalSpace(10.0),
          Checkbox(
            value: filteredUserList.elementAt(index).isSelect ?? false,
            onChanged: (value){
              setState(() {
                filteredUserList.elementAt(index).isSelect = value;
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
          filteredUserList.clear();
        });
        try {
          final ChatUserModel resultModel = await ApiManager.fetchChatUser(
            userId!,
          );

          if (resultModel.error == false) {
            setState(() {
              chatUsers.addAll(resultModel.chatUser);
              filterUsers();
              _isLoading = false;
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

  void createGroup(List<dynamic> selectUsers) {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
          chatUsers.clear();
          filteredUserList.clear();
        });
        try {
          final ResultModel resultModel = await ApiManager.CreateGroup(
            userId!,
            selectUsers
          );

          if (resultModel.error == false) {
            setState(() {
              _isLoading = false;
            });
            for(int i=0;i<selectUsers.length;i++){
              // print("IDs ${selectUsers.elementAt(i)}");
              SendNotification.getToken("Create Group", "You have added in the group", selectUsers.elementAt(i).toString(), "Group Add");
            }
            // chatUser();
            Navigator.of(context).pop();
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
