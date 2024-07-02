import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/result_model.dart';
import 'package:sbo/screens/auth/business_profile_screen.dart';
import 'package:sbo/screens/auth/login_screen.dart';
import 'package:sbo/screens/auth/personal_profile_screen.dart';
import 'package:sbo/screens/subscription_plan_screen.dart';
import 'package:sbo/utils/assets.dart';
import 'package:sbo/utils/connection_utils.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/custom_style.dart';
import 'package:sbo/utils/dimensions.dart';
import 'package:sbo/utils/intentutils.dart';
import 'package:sbo/utils/size.dart';
import 'package:sbo/utils/ui_utils.dart';
import 'package:sbo/widgets/circular_progressbar.dart';

class SelectProfileScreen extends StatefulWidget {

  int userId;
  String mobile,year,name,ccode,yearTo;

  SelectProfileScreen({super.key,required this.yearTo, required this.userId,required this.mobile,required this.year,required this.name,required this.ccode});

  @override
  State<SelectProfileScreen> createState() => _SelectProfileScreenState();
}

class _SelectProfileScreenState extends State<SelectProfileScreen> {

  bool? isPersonal = false, isBusiness = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: CustomColor.whiteColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset(Assets.backIcon),
            ),
          ),
          // actions: [
          //   Text(
          //     "Need Help?",
          //     style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.statusGreen,fontSize: 14.0,fontWeight: FontWeight.w600),
          //   ),
          //   addHorizontalSpace(15.0),
          // ],
        ),
        body: _isLoading ? CircularProgressBar() : _bodyWidget(),
      ),
    );
  }

  _bodyWidget(){
    return Container(
      margin: const EdgeInsets.only(left: 20.0,right: 20.0,bottom: 20.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(Assets.profileselectIcon),
            addVerticalSpace(5.0),
            Text(
              "Select Desired Profile",
              style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.primaryColor,fontWeight: FontWeight.w700,fontSize: 28.0),
            ),
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ut perspiciatis unde omnis iste natus.",
              style: CustomStyle.inputTextStyle.copyWith(fontSize: 14.0,fontWeight: FontWeight.w400,color: CustomColor.newhintColor),
              textAlign: TextAlign.justify,
            ),
            addVerticalSpace(20.0),
            GestureDetector(
              onTap: (){
                setState(() {
                  isPersonal = true;
                  isBusiness = false;
                });
              },
              child: Container(
                height: 50.0,
                padding: const EdgeInsets.only(left: 20.0,right: 20.0),
                decoration: BoxDecoration(
                  color: isPersonal! ? CustomColor.lightsecondaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(color: isPersonal! ? CustomColor.secondaryColor : CustomColor.lightgreyColor,width: 1.0)
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(Assets.checkIcon,color: isPersonal! ? CustomColor.secondaryColor : CustomColor.blackColor,),
                    addHorizontalSpace(20.0),
                    Text(
                      "Personal Use",
                      style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w400,fontSize: 14.0, color: isPersonal! ? CustomColor.secondaryColor : CustomColor.blackColor),
                    )
                  ],
                ),
              ),
            ),
            addVerticalSpace(15.0),
            GestureDetector(
              onTap: (){
                setState(() {
                  isPersonal = false;
                  isBusiness = true;
                });
              },
              child: Container(
                height: 50.0,
                padding: const EdgeInsets.only(left: 20.0,right: 20.0),
                decoration: BoxDecoration(
                    color: isBusiness! ? CustomColor.lightsecondaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(color: isBusiness! ? CustomColor.secondaryColor : CustomColor.lightgreyColor,width: 1.0)
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(Assets.checkIcon,color: isBusiness! ? CustomColor.secondaryColor : CustomColor.blackColor,),
                    addHorizontalSpace(20.0),
                    Text(
                      "Business Use",
                      style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w400,fontSize: 14.0, color: isBusiness! ? CustomColor.secondaryColor : CustomColor.blackColor),
                    )
                  ],
                ),
              ),
            ),
            addVerticalSpace(Dimensions.marginSize * 1.3),
            GestureDetector(
              onTap: (){
                // if(isPersonal!){
                //   IntentUtils.fireIntentwithAnimations(context, const PersonalProfileScreen(), false);
                // } else {
                //   IntentUtils.fireIntentwithAnimations(context, const BusinessProfileScreen(), false);
                // }
                UpdateType();
              },
              child: Container(
                height: 55.0,
                decoration: BoxDecoration(
                  color: CustomColor.primaryColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Center(
                  child: Text(
                    "Next",
                    style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w800,fontSize: 14.0,color: CustomColor.whiteColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void UpdateType() {
    ConnectionUtils.checkConnection().then((intenet) async {
      if (intenet) {
        setState(() {
          _isLoading = true;
        });
        try{

          String type = "";
          if(isPersonal!){
            type = "Personal";
          } else {
            type = "Business";
          }

          final ResultModel resultModel = await ApiManager.UpdateUserType(
            type,widget.userId
          );

          if(resultModel.error == false) {
            setState(() {
              _isLoading = false;
            });

            if(isPersonal!){
              IntentUtils.fireIntentwithAnimations(context, PersonalProfileScreen(
                userId: widget.userId,
                year: widget.year,
                mobile: widget.mobile,
                name: widget.name,
                ccode: widget.ccode,
              ), false);
            } else {
              IntentUtils.fireIntentwithAnimations(context, SubscriptionPlanScreen(
                userId: widget.userId,
                year: widget.year,
                mobile: widget.mobile,
                name: widget.name,
                ccode: widget.ccode,
              ), false);
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

  Future<bool> _onBackPressed() async{
    IntentUtils.fireIntentwithAnimations(context, const LoginScreen(), true);
    return false;
  }
}
