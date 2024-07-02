import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/register_model.dart';
import 'package:sbo/screens/auth/select_profile_screen.dart';
import 'package:sbo/screens/bottom/user_bottom_screen.dart';
import 'package:sbo/utils/assets.dart';
import 'package:sbo/utils/connection_utils.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/custom_style.dart';
import 'package:sbo/utils/dimensions.dart';
import 'package:sbo/utils/intentutils.dart';
import 'package:sbo/utils/prefs.dart';
import 'package:sbo/utils/size.dart';
import 'package:sbo/utils/ui_utils.dart';
import 'package:sbo/widgets/circular_progressbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpVerifyScreen extends StatefulWidget {

  String flag,type,id,token,ccode,mobile,name,year,yearTo;
  OtpVerifyScreen({super.key,required this.flag,required this.type, required this.yearTo ,required this.id,required this.token,
  required this.ccode,required this.mobile,required this.name,required this.year});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {

  var formKey = GlobalKey<FormState>();
  TextEditingController _otpController = TextEditingController();
  var _autoValidate;
  bool _isLoading = false;
  var secondsRemaining = 60;
  String mVerificationId = '';
  var mresend;
  late FirebaseAuth _auth;

  Future<bool> _onBackPressed() async{
    Navigator.of(context).pop();
    return false;
  }

  setData()
  {
    setState(() {
      _autoValidate = AutovalidateMode.disabled;
    });
  }

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    setData();
    sendVerificationCode();
  }

  Future sendVerificationCode() async{
    // await _auth.setSettings(appVerificationDisabledForTesting: true);
    _auth.verifyPhoneNumber(
        phoneNumber: '${widget.ccode}${widget.mobile}',//todo change country code to dubai
        timeout: const Duration(minutes: 1),
        verificationCompleted:(AuthCredential authCredential){
          // signInWithPhoneAuthCredential(authCredential);
        },
        verificationFailed: (FirebaseAuthException authException){
          print(authException.message);
          UIUtils.bottomToast(context: context,text:  "${authException.message}",isError: true);
        },
        codeSent:(String verificationId, [int? forceResendingToken]){
          onCodeSent(verificationId,forceResendingToken);
        },
        codeAutoRetrievalTimeout: (String verificationId){
          mVerificationId = verificationId;
          print(verificationId);
        }
    );
    // initializeTimer();
  }

  Future onCodeSent(String verificationId, [int? forceResendingToken]) async{
    setState(() {
      mVerificationId = verificationId;
      mresend = forceResendingToken;
    });
  }

  Future signInWithPhoneAuthCredential(AuthCredential _credential) async{
    _auth.signInWithCredential(_credential).then((UserCredential result){
      setState(() {
        _isLoading = false;
      });
      passToNextScreen();
    }).catchError((e){
      setState(() {
        _isLoading = false;
      });
      print(e);
      UIUtils.bottomToast(context: context,text:  "Invalid OTP ${e.toString()}",isError: true);
    });
  }

  Future verifyVerificationCode(String code) async
  {
    var _credential = PhoneAuthProvider.credential(verificationId: mVerificationId, smsCode: code);
    signInWithPhoneAuthCredential(_credential);
  }

  Future<void> passToNextScreen() async {
    if(widget.flag == "0") {
      login();
    } else{
      registerUser();
    }
  }

  void initializeTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          secondsRemaining--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: CustomColor.whiteColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: 20.0,
          leading: Container(),
          // leading: IconButton(
          //   onPressed: (){
          //     Navigator.of(context).pop();
          //   },
          //   icon: const Icon(Icons.arrow_back_ios_rounded,color: CustomColor.primaryColor,),
          // ),
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
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(Assets.otpIcon),
              addVerticalSpace(5.0),
              Text(
                "OTP Sent !",
                style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.primaryColor,fontWeight: FontWeight.w700,fontSize: 28.0),
              ),
              Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ut perspiciatis unde omnis iste natus.",
                style: CustomStyle.inputTextStyle.copyWith(fontSize: 14.0,fontWeight: FontWeight.w400,color: CustomColor.newhintColor),
                textAlign: TextAlign.justify,
              ),
              addVerticalSpace(50.0),
              _otpTextField(),
              addVerticalSpace(Dimensions.marginSize),
              GestureDetector(
                onTap: (){
                  if (_otpController.text.isNotEmpty) {
                    setState(() {
                      _isLoading = true;
                    });
                    verifyVerificationCode(_otpController.text);
                  } else {
                    UIUtils.bottomToast(context: context,text:  'Please enter valid OTP!!',isError: true);
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
                      widget.flag == "0" ? "Sign In" : "Sign Up",
                      style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w800,fontSize: 14.0,color: CustomColor.whiteColor),
                    ),
                  ),
                ),
              ),
              addVerticalSpace(Dimensions.marginSize*1.1),
              GestureDetector(
                onTap: (){
                  sendVerificationCode();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn’t received OTP?",
                      style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w400,fontSize: 14.0,color: CustomColor.newhintColor),
                    ),
                    addHorizontalSpace(5.0),
                    Text(
                      "Resend OTP",
                      style: CustomStyle.inputTextStyle.copyWith(fontSize: 14.0,fontWeight: FontWeight.w800,color: CustomColor.secondaryColor),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _otpTextField() {
    return PinCodeTextField(
      length: 6,
      obscureText: false,
      animationType: AnimationType.fade,
      textStyle: CustomStyle.inputTextStyle,
      keyboardType: TextInputType.number,
      autovalidateMode: AutovalidateMode.disabled,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.underline,
        activeColor: CustomColor.hintColor,
        fieldWidth: 50,
        inactiveColor: CustomColor.hintColor,
        inactiveFillColor: Colors.transparent,
        activeFillColor: Colors.transparent,
        selectedColor: CustomColor.primaryColor
      ),
      backgroundColor: Colors.transparent,
      cursorColor: CustomColor.primaryColor,
      enableActiveFill: false,
      autoDisposeControllers: false,
      // errorAnimationController: errorController,
      controller: _otpController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter code';
        }
        return null;
      },
      onCompleted: (v) {
        print("Completed");
      },
      onChanged: (value) {
        print(value);
      },
      beforeTextPaste: (text) {
        print("Allowing to paste $text");
        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
        //but you can show anything you want here, like your pop up saying wrong paste format or etc
        return true;
      }, appContext: context,
    );
  }

  login() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    mPref.setString(Prefs.TOKEN, widget.token);
    mPref.setBool(Prefs.LOGIN, true);
    mPref.setString(Prefs.ID, widget.id);
    mPref.setString(Prefs.TYPE, widget.type);

    IntentUtils.fireIntentwithAnimations(context,  UserBottomScreen(index: 0,), true);
  }

  void registerUser() {
    ConnectionUtils.checkConnection().then((intenet) async {
      if (intenet) {
        setState(() {
          _isLoading = true;
        });
        try{
          final RegisterModel resultModel = await ApiManager.CreateUser(
            widget.name,
            widget.year,
            widget.yearTo,
            widget.mobile,
          );

          if(resultModel.error == false) {
            setState(() {
              _isLoading = false;
            });

            IntentUtils.fireIntentwithAnimations(context, SelectProfileScreen(
              userId: resultModel.userId,
              year: widget.year,
              yearTo: widget.yearTo,
              mobile: widget.mobile,
              ccode: widget.ccode,
              name: widget.name,
            ), true);
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
          print(e.toString());
          UIUtils.bottomToast(context: context, text: e.toString(), isError: true);
        }
      }
      else {
        // No-Internet Case
        UIUtils.bottomToast(context: context, text: "Please check your internet connection", isError: true);
      }
    });
  }
}
