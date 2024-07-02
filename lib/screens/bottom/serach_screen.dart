import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/result_model.dart';
import 'package:sbo/models/user_list_model.dart';
import 'package:sbo/screens/profile_details_screen.dart';
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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  bool _isLoading = false;
  String? userId;
  TextEditingController _searchController = TextEditingController();
  List<AllUser> allUserList = <AllUser>[];
  List<AllUser> filteredUserList = <AllUser>[]; // List to hold filtered results

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

  getPrefs() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String? id = mPref.getString(Prefs.ID);

    setState(() {
      userId = id;
    });

    fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: _isLoading ? CircularProgressBar() : _bodyWidget(),
    );
  }

  void filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredUserList = allUserList.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.type.toLowerCase().contains(query) || user.category.toLowerCase().contains(query);
      }).toList();
    });
  }

  _bodyWidget() {
    return Container(
      margin: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            addVerticalSpace(15.0),
            _searchTextField(),
            addVerticalSpace(15.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${filteredUserList.length} results", // Use filteredUserList length
                    style: CustomStyle.inputTextStyle.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.0,
                      color: CustomColor.hintbgColor,
                    ),
                  ),
                ),
                SvgPicture.asset(Assets.filterIcon),
              ],
            ),
            addVerticalSpace(20.0),
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return rawAccounts(index);
              },
              shrinkWrap: true,
              itemCount: filteredUserList.length,
            )
          ],
        ),
      ),
    );
  }

  _searchTextField() {
    return TextFormField(
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
    );
  }

  rawAccounts(int index) {
    String fStatus = filteredUserList.elementAt(index).fStatus;
    String fuserId = filteredUserList.elementAt(index).reqId;
    dynamic bytes;
    if(filteredUserList.elementAt(index).image != null && filteredUserList.elementAt(index).image.isNotEmpty){
      bytes = base64.decode(filteredUserList.elementAt(index).image);
    } else {
      bytes = null;
    }

    return GestureDetector(
      onTap: () {
        String type = filteredUserList.elementAt(index).type;
        String name = filteredUserList.elementAt(index).name;
        String id = filteredUserList.elementAt(index).id.toString();
        String fStatus = filteredUserList.elementAt(index).fStatus;
        String fuserId = filteredUserList.elementAt(index).reqId;

        IntentUtils.fireIntentwithAnimations(
          context,
          ProfileDetailsScreen(id: id, name: name, type: type, fStatus: fStatus, fuserId: fuserId),
          false,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15.0),
        child: Column(
          children: [
            Row(
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
                addHorizontalSpace(20.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filteredUserList.elementAt(index).name,
                        style: CustomStyle.inputTextStyle.copyWith(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        filteredUserList.elementAt(index).type,
                        style: CustomStyle.inputTextStyle.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: CustomColor.hintbgColor,
                        ),
                      ),
                    ],
                  ),
                ),
                fStatus == "1" && userId != fuserId
                    ? Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          updateRequest(filteredUserList.elementAt(index).fId.toString(), "0", fuserId);
                        },
                        child: SvgPicture.asset(Assets.checkDoneIcon),
                      ),
                      addHorizontalSpace(10.0),
                      GestureDetector(
                        onTap: () {
                          updateRequest(filteredUserList.elementAt(index).fId.toString(), "1", fuserId);
                        },
                        child: SvgPicture.asset(Assets.deleteIcon),
                      ),
                    ],
                  ),
                )
                    : GestureDetector(
                  onTap: () {
                    if (fStatus == "-1" || fStatus == "2") {
                      addRequest(filteredUserList.elementAt(index).id.toString());
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                    decoration: BoxDecoration(
                      color: fStatus == "1" && userId == fuserId
                          ? CustomColor.secondaryColor
                          : fStatus == "0"
                          ? CustomColor.secondaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: CustomColor.secondaryColor),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          fStatus == "0"
                              ? Assets.connectPeopleIcon
                              : fStatus == "1" && userId == fuserId
                              ? Assets.requestedIcon
                              : fStatus == "2" && userId == fuserId
                              ? Assets.connectIcon
                              : Assets.connectIcon,
                          color: fStatus == "1" && userId == fuserId
                              ? CustomColor.whiteColor
                              : fStatus == "0"
                              ? CustomColor.whiteColor
                              : CustomColor.secondaryColor,
                        ),
                        addHorizontalSpace(5.0),
                        Text(
                          fStatus == "0"
                              ? "Connected"
                              : fStatus == "1" && userId == fuserId
                              ? "Requested"
                              : fStatus == "2" && userId == fuserId
                              ? "Connect"
                              : "Connect",
                          style: CustomStyle.inputTextStyle.copyWith(
                            color: fStatus == "1" && userId == fuserId
                                ? CustomColor.whiteColor
                                : fStatus == "0"
                                ? CustomColor.whiteColor
                                : CustomColor.secondaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.0,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            addVerticalSpace(15.0),
            Divider(
              color: Colors.grey.shade200,
              thickness: 1.5,
            ),
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
              allUserList = resultModel.allUsers;
              filterUsers(); // Filter the users after fetching them
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

  void addRequest(String fId) {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
        });
        try {
          final ResultModel resultModel = await ApiManager.SendFollowRequest(
            userId!,
            fId,
          );

          if (resultModel.error == false) {
            setState(() {
              _isLoading = false;
            });
            SendNotification.getToken("New Request", "You have a new request", fId, "Request");
            fetchAllUsers();
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

  void updateRequest(String rId, String status, String fId) {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
        });
        try {
          final ResultModel resultModel = await ApiManager.UpdateFollowRequest(
            rId,
            status,
          );

          if (resultModel.error == false) {
            setState(() {
              _isLoading = false;
            });
            if (status == "0") {
              SendNotification.getToken("Request Update", "Your Request is approved", fId, "Update Status");
            } else {
              SendNotification.getToken("Request Update", "Your Request is declined", fId, "Update Status");
            }
            fetchAllUsers();
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
