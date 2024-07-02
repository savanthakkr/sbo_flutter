import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbo/screens/auth/login_screen.dart';
import 'package:sbo/screens/bottom/user_bottom_screen.dart';
import 'package:sbo/utils/assets.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/custom_style.dart';
import 'package:sbo/utils/dimensions.dart';
import 'package:sbo/utils/intentutils.dart';
import 'package:sbo/utils/prefs.dart';
import 'package:sbo/utils/size.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool _isLoggedIn=false;

  @override
  void initState() {
    super.initState();
    getPrefs();
    Timer(const Duration(seconds: 2),() => navigateUser());
  }

  getPrefs() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool(Prefs.LOGIN) ?? false;
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  navigateUser() async {
    //check if user is logged in
    if(_isLoggedIn) {
      IntentUtils.fireIntentwithAnimations(context, UserBottomScreen(index: 0,), true);
    } else {
      IntentUtils.fireIntentwithAnimations(context, LoginScreen(), true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.whiteColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: _bodyWidget(context),
      ),
    );
  }

  _bodyWidget(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: crossCenter,
        mainAxisAlignment: mainCenter,
        children: [
          SvgPicture.asset(
            Assets.appLogo,
            color: CustomColor.primaryColor,
          ),
          // addVerticalSpace(Dimensions.heightSize),
          // Text('sbo', style: CustomStyle.onboardingTitleStyle,)
        ],
      ),
    );
  }
}
