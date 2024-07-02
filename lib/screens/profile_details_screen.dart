import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/business_profile_model.dart';
import 'package:sbo/models/message_model.dart';
import 'package:sbo/models/personal_profile_model.dart';
import 'package:sbo/models/product_service_model.dart';
import 'package:sbo/models/requirment_model.dart';
import 'package:sbo/models/result_model.dart';
import 'package:sbo/models/sell_it_model.dart';
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

class ProfileDetailsScreen extends StatefulWidget {

  String id,name,type, fStatus, fuserId;

  ProfileDetailsScreen({super.key,required this.id,required this.name,required this.type, required this.fStatus, required this.fuserId});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {

  bool _isLoading = false;
  String? userId;
  List<AllProductService> allProductService = <AllProductService>[];
  String? userType;
  List<SellIt> _messages = <SellIt>[];
  dynamic strUserImage,strCoverImage;
  List<AllRequirment> allReqirments = <AllRequirment>[];
  List<AllRequirment> activeReqirments = <AllRequirment>[];
  String? strPhone,strEmail,strEduction,strEmployment,strAbout,strName,strbName,strEmpcity,strECity,strCategory,strType,strAddress,strAddress2,strState,strCity,strPincode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.type == "Personal"){
      fetchPersonalProfile();
    } else {
      fetchBusinessProfile();
    }
    print(widget.type);
    print(widget.id);
    print("objectobjectobjectobject");
    getPrefs();
  }
  getPrefs() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String? id = mPref.getString(Prefs.ID);
    String? type = mPref.getString(Prefs.TYPE);

    print(id);
    print("object");
    print(widget.fuserId);
    print("object");
    print(widget.fStatus);
    print("object");
    print(widget.id);
    print("object");
    print(widget.type);

    setState(() {
      userId = id;
      userType = type!;
    });

    fetchAllRequirment();
    fetchAllProductService();
    _fetchSellIt();
    print(_messages);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_rounded,color: Colors.black,),
        ),
        titleSpacing: 0,
        title: Text(
          widget.name,
          style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w600,fontSize: 16.0),
        ),
      ),
      body: _isLoading ? CircularProgressBar() : _bodyWidget(),
    );
  }

  _bodyWidget(){
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
                  height: 200,
                  child: Stack(
                    children: [
                      strCoverImage != null && strCoverImage!.isNotEmpty ? Image.memory(strCoverImage!,width: double.infinity,height: 135,fit: BoxFit.cover,) : Image.asset(
                        Assets.appLogoMain,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: 135,
                      ),
                      Positioned(
                        left: 20,
                        top: 70,
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
                        right: 5,
                        top: 150,
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.only(left: 5.0,right: 5.0,top: 7.0,bottom: 7.0),
                          decoration: BoxDecoration(
                              color: CustomColor.secondaryColor,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: CustomColor.secondaryColor)
                          ),
                          child:  Container(
                            padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 5.0,bottom: 5.0),
                            decoration: BoxDecoration(
                                color: widget.fStatus == "1" && userId == widget.fuserId ? CustomColor.secondaryColor : widget.fStatus == "0" ? CustomColor.secondaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: CustomColor.secondaryColor)
                            ),

                            child: Row(
                              children: [
                                SvgPicture.asset(widget.fStatus == "0" ? Assets.connectPeopleIcon : widget.fStatus == "1" && userId == widget.fuserId ? Assets.requestedIcon : widget.fStatus == "2" && userId == widget.fuserId ? Assets.connectIcon : Assets.connectIcon,
                                  color: widget.fStatus == "1" && userId == widget.fuserId ? CustomColor.whiteColor : widget.fStatus == "0" ? CustomColor.whiteColor : CustomColor.secondaryColor,),
                                addHorizontalSpace(5.0),
                                Text(
                                  widget.fStatus == "0" ? "Connected" : widget.fStatus == "1" && userId == widget.fuserId ? "Requested" : widget.fStatus == "2" && userId == widget.fuserId ? "Connect" : "Connect",
                                  style: CustomStyle.inputTextStyle.copyWith(color: widget.fStatus == "1" && userId == widget.fuserId ? CustomColor.whiteColor : widget.fStatus == "-1" ? CustomColor.whiteColor :  widget.fStatus == "0" ? CustomColor.whiteColor : CustomColor.secondaryColor,fontWeight: FontWeight.w600,fontSize: 12.0),
                                )
                              ],
                            ),
                          ),

                          // child: Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     SvgPicture.asset(Assets.connectPeopleIcon,color: CustomColor.whiteColor,),
                          //     addHorizontalSpace(5.0),
                          //     Text(
                          //       "Connected",
                          //       style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.whiteColor,fontWeight: FontWeight.w600,fontSize: 12.0),
                          //     )
                          //   ],
                          // ),
                        ),
                      ),
                    ],
                  ),
                ),
                addVerticalSpace(5.0),
                Container(
                  margin: const EdgeInsets.only(left: 15.0,right: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          strName == null ? "null" : strName!,
                          style: CustomStyle.inputTextStyle.copyWith(fontSize: 20.0,fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.share_rounded,color: CustomColor.blackColor,),
                      addHorizontalSpace(10.0),
                      Text(
                        "Share",
                        style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w600,fontSize: 15.0,color: CustomColor.blackColor),
                      ),
                    ],
                  ),
                ),
                widget.type == "Business" ? Container(
                  margin: const EdgeInsets.only(left: 15.0,right: 15.0),
                  child: Text(
                    "$strCategory | $strType",
                    style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w500,fontSize: 14.0,color: CustomColor.primaryColor),
                  ),
                ) : Container(),
                addVerticalSpace(10.0),
                Container(
                  margin: const EdgeInsets.only(left: 15.0,right: 15.0),
                  child: Text(
                    strAbout == null ? "null" : strAbout!,
                    style: CustomStyle.inputTextStyle.copyWith(fontSize: 14.0,fontWeight: FontWeight.w400),
                    textAlign: TextAlign.justify,
                  ),
                ),
                addVerticalSpace(15.0),
                GestureDetector(
                  onTap: (){

                    if(widget.fStatus == "0"){
                      String type = widget.type;
                      String name = widget.name;
                      String id = widget.id;

                      print(type);
                      print(name);
                      print(id);

                      IntentUtils.fireIntentwithAnimations(context, ChatScreenPersonal(id: id, name: name,type: type,), false);
                    }else{
                      setState(() {
                        _isLoading = false;
                      });
                      UIUtils.bottomToast(context: context, isError: true, text: 'Pending Request');
                    }

                  },
                  child: Container(
                    height: 45.0,
                    margin: const EdgeInsets.only(left: 15.0,right: 15.0),
                    decoration: BoxDecoration(
                        color: CustomColor.primaryColor,
                        borderRadius: BorderRadius.circular(10.0)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(Assets.messageIcon,color: Colors.white,),
                        addHorizontalSpace(10.0),
                        Text(
                          widget.fStatus == "0" ? "Start Chat" : "Pending Request",
                          style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w600,fontSize: 12.0,color: CustomColor.whiteColor),
                        )
                      ],
                    ),
                  ),
                ),
                addVerticalSpace(20.0),
                Container(
                  margin: const EdgeInsets.only(left: 15.0,right: 15.0),
                  child: Divider(
                    color: Colors.grey.shade200,
                    thickness: 1.5,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 15.0,right: 15.0),
                  child: TabBar(
                    // splashBorderRadius: BorderRadius.circular(20),
                    indicatorSize: TabBarIndicatorSize.tab,
                    // padding: const EdgeInsets.all(16),
                    tabAlignment: TabAlignment.fill,
                    dividerHeight: 0,
                    // indicator: BoxDecoration(color: CustomColor.secondaryColor, borderRadius: BorderRadius.circular(20.0)),
                    labelStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: CustomColor.secondaryColor,fontWeight: FontWeight.w600,fontSize: 14.0),
                    unselectedLabelColor: CustomColor.blackColor,
                    indicatorColor: CustomColor.secondaryColor,
                    labelPadding: const EdgeInsets.symmetric(vertical: 4),
                    tabs: [
                      Text(widget.type == "Personal" ? "Contact" : "Details"),
                      Text("Activity"),
                      Text(widget.type == "Personal" ? "Education" : (strType == "Service" ? "Service" : "Product")),
                      Text(widget.type == "Personal" ? "Employment" : "Career"),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
        body: Container(
          margin: const EdgeInsets.only(left: 15.0,right: 15.0,top: 20.0,bottom: 20.0),
          child: TabBarView(
            children: [
              _contactWidget(),
              _activityWidget(),
              widget.type == "Business" ? _productWidget() : _educationWidget(),
              widget.type == "Business" ? _careerWidget() : _employmentWidget(),
            ],
          ),
        ),
      ),
    );
  }

  _contactWidget(){
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        widget.type == "Business" ? Row(
          children: [
            Container(
              height: 50.0,
              width: 50.0,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: strUserImage != null && strUserImage!.isNotEmpty ? Image.memory(strUserImage!).image : Image.asset(Assets.appLogoMain).image),
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
        widget.type == "Business" ? addVerticalSpace(15.0) : Container(),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strAddress == null ? "" : strAddress!,
                  style: CustomStyle.inputTextStyle.copyWith(fontSize: 14.0,fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text(
                      strAddress2 == null ? "" : strAddress2!,
                      style: CustomStyle.inputTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w400),
                    ),
                    Text(
                      strCity != null ? " , $strCity" : "",
                      style: CustomStyle.inputTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w400),
                    ),
                    Text(
                      strState != null ? " , $strState" : "",
                      style: CustomStyle.inputTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w400),
                    ),
                    Text(
                      strPincode != null ? " , $strPincode" : "",
                      style: CustomStyle.inputTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w400),
                    ),
                  ],
                )
              ],
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
                  widget.name,
                  style: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (index < allReqirments.length) {
                    _sendSellIt(allReqirments.elementAt(index).id.toString());
                  } else {
                    // Handle the case where the index is out of bounds
                    print('Invalid index');
                  }
                },
                child: Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: index < _messages.length && _messages.elementAt(index).requirementId == allReqirments.elementAt(index).id.toString() ? CustomColor.secondaryColor : CustomColor.lightGreen,
                    border: Border.all(color: index < _messages.length && _messages.elementAt(index).requirementId == allReqirments.elementAt(index).id.toString() ? CustomColor.secondaryColor : CustomColor.statusGreen),
                  ),
                  child: Text(
                    index < _messages.length && _messages.elementAt(index).requirementId == allReqirments.elementAt(index).id.toString() ? "Done" : "Sell It",
                    style: CustomStyle.inputTextStyle.copyWith(color: index < _messages.length && _messages.elementAt(index).requirementId == allReqirments.elementAt(index).id.toString() ? CustomColor.whiteColor : CustomColor.statusGreen, fontWeight: FontWeight.w600, fontSize: 12.0),
                  ),
                ),
              ),

              addHorizontalSpace(10.0),
              Container(
                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: allReqirments.elementAt(index).status == "1" ? CustomColor.lightinactiveColor : CustomColor.lightGreen,
                  border: Border.all(color: allReqirments.elementAt(index).status == "1" ? CustomColor.inactiveColor : CustomColor.statusGreen),
                ),
                child: Text(
                  allReqirments.elementAt(index).status == "1" ? "Inactive" : "Active",
                  style: CustomStyle.inputTextStyle.copyWith(color: allReqirments.elementAt(index).status == "1" ? CustomColor.inactiveColor : CustomColor.statusGreen, fontWeight: FontWeight.w600, fontSize: 12.0),
                ),
              ),
              addHorizontalSpace(5.0),
            ],
          ),
          addVerticalSpace(30.0),
          Container(
            width: double.infinity,
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
                    "Response: ${allReqirments.elementAt(index).userCount}",
                    style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w700,fontSize: 15.0,color: CustomColor.blackColor),
                  ),
                ),
                addHorizontalSpace(10.0),
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

  void _sendSellIt(String? id) {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = false;
        });
        try {
          final ResultModel resultModel = await ApiManager.ClickSellIt(
            userId!,
            widget.id,
            id!,
          );

          if (!resultModel.error) {
            setState(() {
              _isLoading = false;

            });
            _fetchSellIt();
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
                  strEduction != null ? strEduction! : "",
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
                  strEmployment != null ? strEmployment! : "",
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
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) { return rawProduct(index); },
      itemCount: allProductService.length,

    );
  }

  // rawProduct(int index){
  //   return Container(
  //     height: MediaQuery.of(context).size.width / 2.5,
  //     margin: EdgeInsets.all(3.0),
  //     decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(5.0),
  //         image: DecorationImage(
  //             fit: BoxFit.cover,
  //             image: Image.asset(Assets.dProductBg).image
  //         )
  //     ),
  //   );
  // }

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
          Text(
            allProductService.elementAt(index).title,
            style: TextStyle(
              fontSize: 18.0, // Reduced font size
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
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



  void _fetchSellIt() {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        try {
          final SellItModel resultModel = await ApiManager.fetchClickSellIt(userId!,
            widget.id,

          );

          if (!resultModel.error) {
            setState(() {
              _messages = resultModel.sellit;
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
        UIUtils.bottomToast(
          context: context,
          text: "Please check your internet connection",
          isError: true,
        );
      }
    });
  }

  void fetchAllRequirment() {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
          allReqirments.clear();
          activeReqirments.clear();
        });
        try {
          final RequirmentModel resultModel = await ApiManager.FetchUserRequirment(widget.id!);

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

  void fetchPersonalProfile() {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
        });
        try {
          final PersonalProfileModel resultModel = await ApiManager.FetchPersonalProfile(widget.id);

          if (resultModel.error == false) {
            setState(() {
              strEmail = resultModel.personalProfile.first.email;
              strAbout = resultModel.personalProfile.first.about;
              strEduction = resultModel.personalProfile.first.qualification;
              strEmployment = resultModel.personalProfile.first.employment;
              strPhone = resultModel.personalProfile.first.phone;
              strName = resultModel.personalProfile.first.name;
              strAddress = resultModel.personalProfile.first.address;
              strAddress2 = resultModel.personalProfile.first.homeTown;
              strECity = resultModel.personalProfile.first.qAddress;
              strEmpcity = resultModel.personalProfile.first.oAddress;
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
          // UIUtils.bottomToast(context: context, text: e.toString(), isError: true);
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
          final BusinessProfileModel resultModel = await ApiManager.FetchBusinessProfile(widget.id);

          if (resultModel.error == false) {
            setState(() {
              strEmail = resultModel.businessProfile.first.email;
              strAbout = resultModel.businessProfile.first.description;
              strType = resultModel.businessProfile.first.businessType;
              strCategory = resultModel.businessProfile.first.businessCategory;
              strPhone = resultModel.businessProfile.first.phone;
              strName = resultModel.businessProfile.first.name;
              strbName = resultModel.businessProfile.first.businessName;
              strAddress = resultModel.businessProfile.first.address;
              strAddress2 = resultModel.businessProfile.first.address2;
              strState = resultModel.businessProfile.first.state;
              strCity = resultModel.businessProfile.first.city;
              strPincode = resultModel.businessProfile.first.pincode;
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
            print(strType);
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

  void fetchAllProductService() {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
          allProductService.clear();
        });
        try {
          final ProductServiceModel resultModel = await ApiManager.FetchUserProductService(widget.id!);
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
