import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sbo/screens/auth/login_screen.dart';
import 'package:sbo/screens/saved_requirement.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/custom_style.dart';
import 'package:sbo/utils/intentutils.dart';
import 'package:sbo/utils/prefs.dart';
import 'package:sbo/utils/size.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
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
          "Settings",
          style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w600,fontSize: 16.0),
        ),
      ),
      body: _bodyWidget(),
    );
  }

  _bodyWidget(){
    return Card(
      margin: EdgeInsets.all(15.0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),side: BorderSide(width: 1,color: Colors.grey.shade300)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          addVerticalSpace(10.0),
          GestureDetector(
            onTap: (){
              IntentUtils.fireIntentwithAnimations(context, SavedRequirementScreen(), false);
            },
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Saved Requirement",
                      style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w600,fontSize: 16,color: CustomColor.blackColor),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,color: CustomColor.blackColor,)
                ],
              ),
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Terms of Service",
                    style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w600,fontSize: 16,color: CustomColor.blackColor),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,color: CustomColor.blackColor,)
              ],
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Privacy Policy",
                    style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w600,fontSize: 16,color: CustomColor.blackColor),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,color: CustomColor.blackColor,)
              ],
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Give us Feedback",
                    style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w600,fontSize: 16,color: CustomColor.blackColor),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,color: CustomColor.blackColor,)
              ],
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Delete Account",
                    style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w600,fontSize: 16,color: CustomColor.inactiveColor),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,color: CustomColor.blackColor,)
              ],
            ),
          ),
          Divider(),
          GestureDetector(
            onTap: (){
              logoutUser();
            },
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Text(
                    "Logout",
                    style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w600,fontSize: 16,color: CustomColor.primaryColor),
                  ),
                  addHorizontalSpace(10.0),
                  Icon(Icons.logout_rounded,color: CustomColor.primaryColor,)
                ],
              ),
            ),
          ),
          addVerticalSpace(10.0),
        ],
      ),
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
}
