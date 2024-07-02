import 'dart:convert';
import 'dart:ffi';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/business_profile_model.dart';
import 'package:sbo/models/personal_profile_model.dart';
import 'package:sbo/models/product_service_model.dart';
import 'package:sbo/models/requirment_model.dart';
import 'package:sbo/models/user_list_model.dart';
import 'package:sbo/screens/add_new_productservice.dart';
import 'package:sbo/screens/add_new_requirment_screen.dart';
import 'package:sbo/screens/auth/login_screen.dart';
import 'package:sbo/screens/edit_personal_profile.dart';
import 'package:sbo/screens/edit_product_service.dart';
import 'package:sbo/screens/edit_profile.dart';
import 'package:sbo/screens/send_message_share.dart';
import 'package:sbo/screens/setting_screen.dart';
import 'package:sbo/utils/assets.dart';
import 'package:sbo/utils/connection_utils.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/custom_style.dart';
import 'package:sbo/utils/intentutils.dart';
import 'package:sbo/utils/size.dart';
import 'package:sbo/utils/ui_utils.dart';
import 'package:sbo/widgets/circular_progressbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/result_model.dart';
import '../../utils/prefs.dart';

class AccountScreen extends StatefulWidget {

  AccountScreen({super.key,});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  bool _isLoading = false;
  String? userId;
  int current = 0;
  List<AllRequirment> allReqirments = <AllRequirment>[];
  List<AllUser> allUserList = <AllUser>[];
  List<AllRequirment> activeReqirments = <AllRequirment>[];

  List<AllProductService> allProductService = <AllProductService>[];
  String? userType;
  String? totalUserCount = "0";
  dynamic strUserImage,strCoverImage;
  String? strPhone,strEmail,strEduction,strEmployment,strAbout,strName,strbName,strCategory,strType, strAddress, strECity, strEmpcity, strHomeTown;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefs();
  }

  getPrefs() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String? id = mPref.getString(Prefs.ID);
    String? type = mPref.getString(Prefs.TYPE);

    setState(() {
      userId = id!;
      userType = type!;
    });
    if(userType == "Personal"){
      fetchPersonalProfile();
    } else {
      fetchBusinessProfile();
    }
    print(allProductService);

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
              totalUserCount = resultModel.userCount.toString();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     onPressed: (){
      //       Navigator.of(context).pop();
      //     },
      //     icon: const Icon(Icons.arrow_back_ios_rounded,color: Colors.black,),
      //   ),
      //   titleSpacing: 0,
      //   title: Text(
      //     strName == null ? "" : strName!,
      //     style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w600,fontSize: 16.0),
      //   ),
      //   actions: [
      //     IconButton(
      //         onPressed: (){
      //
      //         },
      //         icon: Icon(Icons.edit_rounded,color: CustomColor.primaryColor,)
      //     ),
      //     IconButton(
      //         onPressed: (){
      //           logoutUser();
      //         },
      //         icon: Icon(Icons.logout_rounded,color: CustomColor.primaryColor,)
      //     ),
      //   ],
      // ),
      body: _isLoading ? CircularProgressBar() : _bodyWidget(),
    );
  }

  logoutUser() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    mPref.setString(Prefs.TOKEN,"");
    mPref.setBool(Prefs.LOGIN, false);
    mPref.setString(Prefs.ID, "");
    mPref.setString(Prefs.TYPE, "");

    IntentUtils.fireIntentwithAnimations(context, const LoginScreen(), true);
  }

  _bodyWidget() {
    return DefaultTabController(
      length: 4,
      child: NestedScrollView(
        scrollDirection: Axis.vertical,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 210,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      strCoverImage != null && strCoverImage!.isNotEmpty ? Image.memory(strCoverImage!,width: double.infinity,height: 170,fit: BoxFit.cover,) : Image.asset(
                        Assets.appLogoMain,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: 170,
                      ),
                      Positioned(
                        left: 20,
                        top: 105,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: strUserImage != null && strUserImage!.isNotEmpty ? Image.memory(strUserImage!).image : Image.asset(Assets.appLogoMain).image,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 40,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.settings, color: Colors.white,size: 30),
                              onPressed: () {
                                IntentUtils.fireIntentwithAnimations(context, SettingScreen(), false);
                              },
                            ),
                             GestureDetector(
                              onTap: (){
                                IntentUtils.fireIntentwithAnimations(context, userType == "Personal" ? EditPersonalProfileScreen() : EditProfileScreen(), false);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  Assets.editUserIcon,
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                addVerticalSpace(15.0),
                Container(
                  margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Row(
                    children: [
                      Text(
                        strName == null ? "" : strName!,
                        style: CustomStyle.inputTextStyle.copyWith(
                            fontSize: 20.0, fontWeight: FontWeight.w600),
                      ),
                      addHorizontalSpace(20.0),
                      GestureDetector(
                        onTap: (){
                          addSchoolPopup();
                        },
                          child: SvgPicture.asset(Assets.editUserIcon)
                      ),
                    ],
                  ),
                ),
                userType == "Business"
                    ? Container(
                  margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    "$strCategory | $strType",
                    style: CustomStyle.inputTextStyle.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.0,
                        color: CustomColor.primaryColor),
                  ),
                )
                    : Container(),
                addVerticalSpace(10.0),
                Container(
                  margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    strAbout == null ? "" : strAbout!,
                    style: CustomStyle.inputTextStyle.copyWith(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                addVerticalSpace(5.0),
                Container(
                  height: 45.0,
                  margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(Assets.twoUserIcon,
                          color: CustomColor.connectionTextColor),
                      addHorizontalSpace(10.0),
                      Text(
                        "${totalUserCount} Connection",
                        style: CustomStyle.inputTextStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.0,
                          color: CustomColor.connectionTextColor,
                        ),
                      )
                    ],
                  ),
                ),
                addVerticalSpace(5.0),
                Container(
                  margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Divider(
                    color: Colors.grey.shade200,
                    thickness: 1.5,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: TabBar(
                    // splashBorderRadius: BorderRadius.circular(20),
                    indicatorSize: TabBarIndicatorSize.tab,
                    // padding: const EdgeInsets.all(16),
                    tabAlignment: TabAlignment.fill,
                    dividerHeight: 0,
                    // indicator: BoxDecoration(color: CustomColor.secondaryColor, borderRadius: BorderRadius.circular(20.0)),
                    labelStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: CustomColor.secondaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0),
                    unselectedLabelColor: CustomColor.blackColor,
                    indicatorColor: CustomColor.secondaryColor,
                    labelPadding: const EdgeInsets.symmetric(vertical: 4),
                    tabs: [
                      Text(userType == "Personal" ? "Contact" : "Details"),
                      Text("Activity"),
                      // Text(userType == "Personal" ? "Education" : "Product/Service"),
                      Text(userType == "Personal"
                          ? "Education"
                          : (strType == "Service" ? "Service" : "Product")),
                      Text(
                          userType == "Personal" ? "Employment" : "Career"),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
        body: Container(
          margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 20.0),
          child: TabBarView(
            children: [
              _contactWidget(),
              _activityWidget(),
              userType == "Business" ? _productWidget() : _educationWidget(),
              userType == "Business" ? _careerWidget() : _employmentWidget(),
            ],
          ),
        ),
      ),
    );
  }


  addSchoolPopup() async {
    final _formKey = GlobalKey<FormState>();
    String? _radioValue;
    TextEditingController _nameController = TextEditingController();
    TextEditingController _yearController = TextEditingController();
    TextEditingController _yearControllerto = TextEditingController();

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
                                  "Update Profile",
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
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.text,
                          cursorColor: CustomColor.primaryColor,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Name',
                            labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
                            border: UIUtils.textinputborder,
                            contentPadding: UIUtils.textinputPadding,
                            errorBorder: UIUtils.errorBorder,
                            enabledBorder: UIUtils.textinputborder,
                            focusedBorder: UIUtils.focusedBorder,
                            filled: false,
                            counterText: '',
                            hintText: "Name",
                            hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
                            // fillColor: CustomColor.editTextColor,
                          ),
                          style: CustomStyle.inputTextStyle,
                          textAlign: TextAlign.start,
                          autovalidateMode: AutovalidateMode.disabled,
                          validator: (value){
                            if(value!.isEmpty || value.length < 3){
                              return 'Enter valid name';
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 15.0,),
                        TextFormField(
                          controller: _yearController,
                          keyboardType: TextInputType.number,
                          cursorColor: CustomColor.primaryColor,
                          maxLength: 4,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Batch Year From',
                            labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
                            border: UIUtils.textinputborder,
                            contentPadding: UIUtils.textinputPadding,
                            errorBorder: UIUtils.errorBorder,
                            enabledBorder: UIUtils.textinputborder,
                            focusedBorder: UIUtils.focusedBorder,
                            filled: false,
                            counterText: '',
                            hintText: "Batch Year From-To YYYY",
                            hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
                            // fillColor: CustomColor.editTextColor,
                          ),
                          style: CustomStyle.inputTextStyle,
                          textAlign: TextAlign.start,
                          autovalidateMode: AutovalidateMode.disabled,
                          validator: (value){
                            if(value!.isEmpty || value.length < 4){
                              return 'Enter valid batch year';
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 15.0,),
                        TextFormField(
                          controller: _yearControllerto,
                          keyboardType: TextInputType.number,
                          cursorColor: CustomColor.primaryColor,
                          maxLength: 4,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Batch Year To',
                            labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
                            border: UIUtils.textinputborder,
                            contentPadding: UIUtils.textinputPadding,
                            errorBorder: UIUtils.errorBorder,
                            enabledBorder: UIUtils.textinputborder,
                            focusedBorder: UIUtils.focusedBorder,
                            filled: false,
                            counterText: '',
                            hintText: "Batch Year To YYYY",
                            hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
                            // fillColor: CustomColor.editTextColor,
                          ),
                          style: CustomStyle.inputTextStyle,
                          textAlign: TextAlign.start,
                          autovalidateMode: AutovalidateMode.disabled,
                          validator: (value){
                            if(value!.isEmpty || value.length < 4){
                              return 'Enter valid batch year';
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 30,),
                        GestureDetector(
                          onTap: (){
                            if(_nameController.text.isEmpty && _yearController.text.isEmpty && _yearControllerto.text.isEmpty){
                              UIUtils.bottomToast(context: context, text: "Please Fill All Fields", isError: true);
                            }else{
                              Navigator.of(context).pop();
                              UpdateType(_nameController.text.trim(),_yearController.text.trim(),_yearControllerto.text.trim());
                            }

                          },
                          child: Container(
                            height: 55.0,
                            decoration: BoxDecoration(
                              color: CustomColor.primaryColor,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Center(
                              child: Text(
                                "Update",
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

  void UpdateType(String name, String bYear, String byearto) {

    ConnectionUtils.checkConnection().then((intenet) async {
      if (intenet) {
        setState(() {
          _isLoading = true;
        });
        try{

          final ResultModel resultModel = await ApiManager.UpdateUserName(
            userId!,
            name,
            bYear,
            byearto,
          );

          if(resultModel.error == false) {
            setState(() {
              _isLoading = false;
            });
            if(userType == "Personal"){
              fetchPersonalProfile();
            } else {
              fetchBusinessProfile();
            }
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

  _contactWidget(){
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        userType == "Business" ? Row(
          children: [
            Container(
              height: 50.0,
              width: 50.0,
              // backgroundImage: strUserImage != null && strUserImage!.isNotEmpty ? Image.memory(strUserImage!).image : Image.asset(Assets.appLogoMain).image,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: strUserImage != null && strUserImage!.isNotEmpty ? Image.memory(strUserImage!).image : Image.asset(Assets.appLogoMain).image)
              ),
            ),
            addHorizontalSpace(20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strName == null ? "" : strName!,
                  style: CustomStyle.inputTextStyle.copyWith(fontSize: 14.0,fontWeight: FontWeight.w600),
                ),
                Text(
                  "Owner $strbName",
                  style: CustomStyle.inputTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w400),
                ),
              ],
            )
          ],
        ) : Container(),
        userType == "Business" ? addVerticalSpace(15.0) : Container(),
        Row(
          children: [
            SvgPicture.asset(Assets.contactIcon),
            addHorizontalSpace(20.0),
            Text(
              strPhone == null ? "" : strPhone!,
              style: CustomStyle.inputTextStyle.copyWith(fontSize: 14.0,fontWeight: FontWeight.w400),
            )
          ],
        ),
        addVerticalSpace(15.0),
        Row(
          children: [
            SvgPicture.asset(Assets.emailIcon),
            addHorizontalSpace(20.0),
            Text(
              strEmail == null ? "" : strEmail!,
              style: CustomStyle.inputTextStyle.copyWith(fontSize: 14.0,fontWeight: FontWeight.w400),
            )
          ],
        ),
        addVerticalSpace(15.0),
        Row(
          children: [
            SvgPicture.asset(Assets.mapIcon),
            addHorizontalSpace(20.0),
            Flexible(
              child: Text(
                strAddress == null ? "" : strAddress!,
                style: CustomStyle.inputTextStyle.copyWith(fontSize: 14.0,fontWeight: FontWeight.w400),
              ),
            )
          ],
        )
      ],
    );
  }

  _activityWidget(){
    return ListView.builder(
      itemBuilder: (context,index){
        return rawActivity(index);
      },
      itemCount: allReqirments.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }



  rawActivity(int index){
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 50.0,
                width: 50.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: strUserImage != null && strUserImage!.isNotEmpty ? Image.memory(strUserImage!).image : Image.asset(Assets.appLogoMain).image),
                ),
              ),
              addHorizontalSpace(10.0),
              Expanded(
                child: Text(
                  strName == null ? "" : strName!,
                  style: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 5.0,bottom: 5.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: allReqirments.elementAt(index).status == "1" ? CustomColor.lightinactiveColor : CustomColor.lightGreen,
                    border: Border.all(color: allReqirments.elementAt(index).status == "1" ? CustomColor.inactiveColor : CustomColor.statusGreen)
                ),
                child: Text(
                  allReqirments.elementAt(index).status == "1" ? "Inactive" : "Active",
                  style: CustomStyle.inputTextStyle.copyWith(color: allReqirments.elementAt(index).status == "1" ? CustomColor.inactiveColor : CustomColor.statusGreen,fontWeight: FontWeight.w600,fontSize: 12.0),
                ),
              ),
              addHorizontalSpace(5.0),
            ],
          ),
          addVerticalSpace(30.0),
          Container(
            width: double.infinity, // Set width to 100% of the available width
            padding: const EdgeInsets.all(15.0),
            decoration: const BoxDecoration(
              color: CustomColor.lightsecondaryColor,
            ),
            child: Text(
              allReqirments.elementAt(index).title,
              style: CustomStyle.inputTextStyle.copyWith(
                color: CustomColor.secondaryColor,
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          addVerticalSpace(20.0),
          Container(
            margin: const EdgeInsets.only(left: 15.0,right: 15.0),
            child: Text(
              allReqirments.elementAt(index).description,
              style: CustomStyle.inputTextStyle.copyWith(fontSize: 15.0,fontWeight: FontWeight.w400),
            ),
          ),
          addVerticalSpace(20.0),
          Container(
            margin: const EdgeInsets.only(left: 15.0,right: 15.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Response: ${allReqirments.elementAt(index).userCount.toString()}",
                    style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w700,fontSize: 15.0,color: CustomColor.blackColor),
                  ),
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

  _educationWidget(){
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          children: [
            SvgPicture.asset(Assets.employmentIcon),
            addHorizontalSpace(20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strEduction == null ? "" : strEduction!,
                  style: CustomStyle.inputTextStyle.copyWith(fontSize: 14.0,fontWeight: FontWeight.w600),
                ),
                Text(
                  strECity == null ? "" : strECity!,
                  style: CustomStyle.inputTextStyle.copyWith(fontSize: 13.0,fontWeight: FontWeight.w400),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  _employmentWidget(){
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          children: [
            SvgPicture.asset(Assets.employmentIcon),
            addHorizontalSpace(20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strEmployment == null ? "" : strEmployment!,
                  style: CustomStyle.inputTextStyle.copyWith(fontSize: 14.0,fontWeight: FontWeight.w600),
                ),
                Text(
                  strEmpcity == null ? "" : strEmpcity!,
                  style: CustomStyle.inputTextStyle.copyWith(fontSize: 13.0,fontWeight: FontWeight.w400),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  _productWidget(){
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: (){
              // IntentUtils.fireIntentwithAnimations(context, AddNewProductServiceScreen(strType: strType), false);
              Navigator.of(context).push(PageRouteBuilder(

                // transitionDuration: Duration(seconds: 2),
                pageBuilder: (_, __, ___) {
                  return AddNewProductServiceScreen(strType: strType);
                },
              )
              ).then((onValue){
                fetchAllRequirment();
              });
            },
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                color: CustomColor.primaryColor,
                borderRadius: BorderRadius.circular(11.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(Assets.addUnfillIcon,color: Colors.white,),
                  addHorizontalSpace(10.0),
                  Text(
                    strType == "Service" ? "Add New Service" : strType == "Product" ? "Add New Product" : "Add New Requirement",
                    style: CustomStyle.inputTextStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.0,
                    ),
                  )
                ],
              ),
            ),
          ),
          addVerticalSpace(10.0),
          Expanded(
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) { return rawProduct(index); },
              itemCount: allProductService.length,

            ),
          ),
        ],
      ),
    );
  }


  rawProductImage(Images image){
    return Container(
      height: MediaQuery.of(context).size.width / 2.5,
      margin: EdgeInsets.all(3.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          image: DecorationImage(
              fit: BoxFit.cover,
              image: Image.memory(base64Decode(image.url)).image,
          )
      ),
    );
  }




  rawProduct(int index){
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Reduced padding
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  allProductService.elementAt(index).title,
                  style: CustomStyle.inputTextStyle.copyWith(fontSize: 18.0,fontWeight: FontWeight.w600,color: CustomColor.blackColor),
                ),
              ),
              addHorizontalSpace(5.0),
              InkWell(
                onTap: (){
                  Navigator.of(context).push(PageRouteBuilder(

                    // transitionDuration: Duration(seconds: 2),
                    pageBuilder: (_, __, ___) {
                      return EditProductService(id: allProductService.elementAt(index).id.toString());
                    },
                  )
                  ).then((onValue){
                    fetchAllRequirment();
                  });
                  // IntentUtils.fireIntentwithAnimations(context, EditProductService(id: allProductService.elementAt(index).id.toString()), false);
                },

                child: SvgPicture.asset(Assets.editUserIcon),
              )
            ],
          ),
          SizedBox(height: 8), // Reduced space
          Text(
            // "hello",
            allProductService.elementAt(index).description,
            style: TextStyle(
              fontSize: 11.0, // Reduced font size
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 15), // Reduced space
          allProductService.elementAt(index).images.isNotEmpty ? Container(
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                shrinkWrap: true,

                childAspectRatio: 1 / 1,
                children: List.generate(allProductService.elementAt(index).images.length, (indexImage) {
                  return rawProductImage(allProductService.elementAt(index).images.elementAt(indexImage));
                }),
              ),
          ) : Container(),
        ],
      ),
    );
  }


  _careerWidget(){
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [

      ],
    );
  }

  void fetchPersonalProfile() {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
        });
        try {
          final PersonalProfileModel resultModel = await ApiManager.FetchPersonalProfile(userId!);

          if (resultModel.error == false) {
            setState(() {
              strEmail = resultModel.personalProfile.first.email;
              strAbout = resultModel.personalProfile.first.about;
              strEduction = resultModel.personalProfile.first.qualification;
              strEmployment = resultModel.personalProfile.first.employment;
              strPhone = resultModel.personalProfile.first.phone;
              strName = resultModel.personalProfile.first.name;
              strAddress = resultModel.personalProfile.first.address;
              strECity = resultModel.personalProfile.first.qAddress;
              strEmpcity = resultModel.personalProfile.first.oAddress;
              strHomeTown = resultModel.personalProfile.first.homeTown;
              if(resultModel.personalProfile.first.profile != null || resultModel.personalProfile.first.profile != ""){
                String userImage = resultModel.personalProfile.first.profile;
                strUserImage = base64.decode(userImage);
              }
              if(resultModel.personalProfile.first.cover != null || resultModel.personalProfile.first.cover != ""){
                String CoverImage = resultModel.personalProfile.first.cover;
                strCoverImage = base64.decode(CoverImage);
              }
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
        fetchAllRequirment();
        fetchAllRequirments();
        fetchAllUsers();
      } else {
        // No-Internet Case
        UIUtils.bottomToast(
            context: context,
            text: "Please check your internet connection",
            isError: true);
      }
    });
  }
  void fetchAllRequirments() {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
          allReqirments.clear();
          activeReqirments.clear();
        });
        try {
          final RequirmentModel resultModel = await ApiManager.FetchUserRequirment(userId!);

          if (resultModel.error == false) {
            setState(() {
              _isLoading = false;
              allReqirments = resultModel.allRequirment;
            });

            print(allReqirments);
            for(int i=0;i<resultModel.allRequirment.length;i++){
              if(resultModel.allRequirment.elementAt(i).status == "1"){
                setState(() {
                  activeReqirments.add(resultModel.allRequirment.elementAt(i));
                });
              }
            }
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

  void fetchBusinessProfile() {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
        });
        try {
          final BusinessProfileModel resultModel = await ApiManager.FetchBusinessProfile(userId!);

          if (resultModel.error == false) {
            setState(() {
              strEmail = resultModel.businessProfile.first.email;
              strAbout = resultModel.businessProfile.first.description;
              strType = resultModel.businessProfile.first.businessType;
              strCategory = resultModel.businessProfile.first.businessCategory;
              strPhone = resultModel.businessProfile.first.phone;
              strName = resultModel.businessProfile.first.name;
              strAddress = resultModel.businessProfile.first.address;
              strbName = resultModel.businessProfile.first.businessName;
              if(resultModel.businessProfile.first.profile != null || resultModel.businessProfile.first.profile != ""){
                String userImage = resultModel.businessProfile.first.profile;
                strUserImage = base64.decode(userImage);
              }
              if(resultModel.businessProfile.first.cover != null || resultModel.businessProfile.first.cover != ""){
                String CoverImage = resultModel.businessProfile.first.cover;
                strCoverImage = base64.decode(CoverImage);
              }
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
        fetchAllRequirment();
        fetchAllRequirments();
        fetchAllUsers();
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
          allProductService.clear();
        });
        try {
          final ProductServiceModel resultModel = await ApiManager.FetchUserProductService(userId!);
          print(userId);
          if (resultModel.error == false) {
            setState(() {
              _isLoading = false;
              allProductService = resultModel.allProductService;
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

}
