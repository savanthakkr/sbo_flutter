import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/login_model.dart';
import 'package:sbo/models/result_model.dart';
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
import 'dart:io' as Io;

class PersonalProfileScreen extends StatefulWidget {

  int userId;
  String mobile,year,name,ccode;

  PersonalProfileScreen({super.key,required this.userId,required this.mobile,required this.year,required this.name,required this.ccode});

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {

  bool _isLoading = false;
  var formKey = GlobalKey<FormState>();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _homeTownController = TextEditingController();
  TextEditingController _qualificationController = TextEditingController();
  TextEditingController _occupationController = TextEditingController();
  TextEditingController _employmentController = TextEditingController();
  TextEditingController _occupationCityController = TextEditingController();
  TextEditingController _qualificationCityController = TextEditingController();
  TextEditingController _aboutController = TextEditingController();
  String? profileImgurl,coverImage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData(){
    setState(() {
      _mobileController.text = widget.ccode+" "+widget.mobile;
      _yearController.text = widget.year;
      _nameController.text = widget.name;
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
          leading: GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset(Assets.backIcon),
            ),
          ),
          title: Text(
            "Personal Profile",
            style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.primaryColor,fontWeight: FontWeight.w700,fontSize: 28.0),
          ),
        ),
        body: _isLoading ? CircularProgressBar() : _bodyWidget(),
      ),
    );
  }

  _bodyWidget(){
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              addVerticalSpace(20.0),
              GestureDetector(
                onTap:(){
                  checkPermission(false);
                },
                child: Container(
                  height: 150.0,
                  padding: const EdgeInsets.all(15.0),
                  decoration: coverImage == null || coverImage!.isEmpty ? BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: CustomColor.lightsecondaryColor
                  ) : BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: Image.memory(base64Decode(coverImage!,),fit: BoxFit.cover,).image
                    )
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap:(){
                          checkPermission(false);
                        },
                        child: coverImage == null || coverImage!.isEmpty ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Add Cover Image",
                              style: CustomStyle.inputTextStyle.copyWith(fontSize: 14.0,fontWeight: FontWeight.w400,color: CustomColor.secondaryColor),
                            ),
                            addHorizontalSpace(10.0),
                            Container(
                              height: 25.0,
                              width: 25.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: CustomColor.secondaryColor)
                              ),
                              child: Center(child: SvgPicture.asset(Assets.editIcon,color: CustomColor.secondaryColor,)),
                            )
                          ],
                        ) : Container(),
                      ),
                      addVerticalSpace(20.0),
                      GestureDetector(
                        onTap: (){
                          checkPermission(true);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 65.0,
                              width: 65.0,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: CustomColor.secondaryColor)
                              ),
                              child: profileImgurl == null || profileImgurl!.isEmpty ? Center(child: SvgPicture.asset(Assets.usereditIcon,color: CustomColor.secondaryColor,)) : ClipRRect(
                                  borderRadius: BorderRadius.circular(65),
                                  child: Image.memory(base64Decode(profileImgurl!,),fit: BoxFit.cover,)),
                            ),
                            addHorizontalSpace(10.0),
                            profileImgurl == null || profileImgurl!.isEmpty ? Text(
                              "Setup Profile picture",
                              style: CustomStyle.inputTextStyle.copyWith(fontSize: 14.0,fontWeight: FontWeight.w400,color: CustomColor.secondaryColor),
                            ) : Container(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              addVerticalSpace(Dimensions.marginSize),
              _nameTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _mobileTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _yearTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _emailTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _qualificationTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _qualificationCityTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _occupationTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _employmentTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _occupationCityTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _aboutTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _addressTextField(),
              addVerticalSpace(Dimensions.marginSize * 2),
              _homeTownTextField(),
              addVerticalSpace(Dimensions.marginSize * 2),
              GestureDetector(
                onTap: (){
                  // IntentUtils.fireIntentwithAnimations(context, const UserBottomScreen(), true);
                  verify();
                },
                child: Container(
                  height: 55.0,
                  decoration: BoxDecoration(
                    color: CustomColor.primaryColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
                    child: Text(
                      "Finish",
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

  _nameTextField() {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.text,
      cursorColor: CustomColor.primaryColor,
      readOnly: true,
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
    );
  }

  _yearTextField() {
    return TextFormField(
      controller: _yearController,
      keyboardType: TextInputType.number,
      cursorColor: CustomColor.primaryColor,
      maxLength: 4,
      readOnly: true,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Batch Year',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Batch Year",
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
    );
  }
  _mobileTextField() {
    return TextFormField(
      controller: _mobileController,
      keyboardType: TextInputType.number,
      cursorColor: CustomColor.primaryColor,
      readOnly: true,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Mobile Number',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Mobile Number",
        hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
        // fillColor: CustomColor.editTextColor,
      ),
      style: CustomStyle.inputTextStyle,
      textAlign: TextAlign.start,
      autovalidateMode: AutovalidateMode.disabled,
    );
  }



  _addressTextField() {
    return TextFormField(
      controller: _addressController,
      keyboardType: TextInputType.multiline,
      cursorColor: CustomColor.primaryColor,
      maxLines: 3,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Address',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Enter Address (max 100 word)",
        hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
        // fillColor: CustomColor.editTextColor,
      ),
      style: CustomStyle.inputTextStyle,
      textAlign: TextAlign.start,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value){
        if(value!.isEmpty){
          return 'Please enter your About';
        }

        return null;
      },
    );
  }

  _homeTownTextField() {
    return TextFormField(
      controller: _homeTownController,
      keyboardType: TextInputType.multiline,
      cursorColor: CustomColor.primaryColor,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Home Town',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        hintText: "Home Town",
        hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
        // fillColor: CustomColor.editTextColor,
      ),
      style: CustomStyle.inputTextStyle,
      textAlign: TextAlign.start,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value){
        if(value!.isEmpty){
          return 'Please enter your home Town';
        }

        return null;
      },
    );
  }

  _emailTextField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      cursorColor: CustomColor.primaryColor,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Email',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Email",
        hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
        // fillColor: CustomColor.editTextColor,
      ),
      style: CustomStyle.inputTextStyle,
      textAlign: TextAlign.start,
      autovalidateMode: AutovalidateMode.disabled,
      validator: emailValidator,
    );
  }

  _qualificationTextField() {
    return TextFormField(
      controller: _qualificationController,
      keyboardType: TextInputType.text,
      cursorColor: CustomColor.primaryColor,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Qualification',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Qualification",
        hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
        // fillColor: CustomColor.editTextColor,
      ),
      style: CustomStyle.inputTextStyle,
      textAlign: TextAlign.start,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value){
        if(value!.isEmpty){
          return 'Please enter your Qualification';
        }

        return null;
      },
    );
  }

  _occupationTextField() {
    return TextFormField(
      controller: _occupationController,
      keyboardType: TextInputType.text,
      cursorColor: CustomColor.primaryColor,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Occupation',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Occupation",
        hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
        // fillColor: CustomColor.editTextColor,
      ),
      style: CustomStyle.inputTextStyle,
      textAlign: TextAlign.start,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value){
        if(value!.isEmpty){
          return 'Please enter your Occupation';
        }

        return null;
      },
    );
  }

  _qualificationCityTextField() {
    return TextFormField(
      controller: _qualificationCityController,
      keyboardType: TextInputType.text,
      cursorColor: CustomColor.primaryColor,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Qualification City',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Qualification City",
        hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
        // fillColor: CustomColor.editTextColor,
      ),
      style: CustomStyle.inputTextStyle,
      textAlign: TextAlign.start,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value){
        if(value!.isEmpty){
          return 'Please enter your Qualification';
        }

        return null;
      },
    );
  }

  _occupationCityTextField() {
    return TextFormField(
      controller: _occupationCityController,
      keyboardType: TextInputType.text,
      cursorColor: CustomColor.primaryColor,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Employment City',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Employment City",
        hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
        // fillColor: CustomColor.editTextColor,
      ),
      style: CustomStyle.inputTextStyle,
      textAlign: TextAlign.start,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value){
        if(value!.isEmpty){
          return 'Please enter your Occupation';
        }

        return null;
      },
    );
  }

  _employmentTextField() {
    return TextFormField(
      controller: _employmentController,
      keyboardType: TextInputType.text,
      cursorColor: CustomColor.primaryColor,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Employment',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Employment",
        hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
        // fillColor: CustomColor.editTextColor,
      ),
      style: CustomStyle.inputTextStyle,
      textAlign: TextAlign.start,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value){
        if(value!.isEmpty){
          return 'Please enter your Employment';
        }

        return null;
      },
    );
  }

  _aboutTextField() {
    return TextFormField(
      controller: _aboutController,
      keyboardType: TextInputType.multiline,
      cursorColor: CustomColor.primaryColor,
      maxLines: 5,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'About',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Enter about you (max 100 word)",
        hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
        // fillColor: CustomColor.editTextColor,
      ),
      style: CustomStyle.inputTextStyle,
      textAlign: TextAlign.start,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value){
        if(value!.isEmpty){
          return 'Please enter your About';
        }

        return null;
      },
    );
  }

  verify(){
    if(formKey.currentState!.validate()){
      String pUrl = "",cUrl = "";
      if(profileImgurl == null || profileImgurl!.isEmpty){
        setState(() {
          pUrl = "";
        });
      } else {
        setState(() {
          pUrl = profileImgurl!;
        });
      }

      if(coverImage == null || coverImage!.isEmpty){
        setState(() {
          cUrl = "";
        });
      } else {
        setState(() {
          cUrl = coverImage!;
        });
      }

      registerUser(pUrl,cUrl);
    }
  }

  checkPermission(bool isProfile) async{
    if (Io.Platform.isAndroid) {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      debugPrint('MY_SDK : ${androidInfo.version.sdkInt}');
      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.photos.request();
        // final status2 = await Permission.camera.request();
        if (status == PermissionStatus.granted) {
          print('Permission granted.');
          openProfileImage(isProfile);
        } else if (status == PermissionStatus.denied) {
          print(
              'Permission denied. Show a dialog and again ask for the permission');
          await Permission.storage.shouldShowRequestRationale;
        }
      }
      else{
        final status = await Permission.storage.request();
        // final status2 = await Permission.camera.request();
        if (status == PermissionStatus.granted) {
          print('Permission granted.');
          openProfileImage(isProfile);
        } else if (status == PermissionStatus.denied) {
          print(
              'Permission denied. Show a dialog and again ask for the permission');
          await Permission.storage.shouldShowRequestRationale;
        }
      }
    }
  }

  openProfileImage(bool isProfile) async {
    setState(() {
      if(isProfile) {
        profileImgurl = "";
      } else {
        coverImage = "";
      }
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image,allowMultiple: false);

    if (result != null) {
      setState(() {
        String fileName = result.files.first.name;
        print("fileName ${fileName}");

        String? filePath = result.files.first.path;
        final bytes = Io.File(filePath!).readAsBytesSync();
        if(isProfile) {
          profileImgurl = base64Encode(bytes);
        } else {
          coverImage = base64Encode(bytes);
        }
      });
    } else {

    }
    setState(() {});
  }

  void registerUser(String profile,String cover) {
    ConnectionUtils.checkConnection().then((intenet) async {
      if (intenet) {
        setState(() {
          _isLoading = true;
        });
        try{
          final ResultModel resultModel = await ApiManager.CreatePersonalProfile(
            widget.userId.toString(),
            _emailController.text.trim(),
            _qualificationController.text.trim(),
            _qualificationCityController.text.trim(),
            _occupationController.text.trim(),
            _occupationCityController.text.trim(),
            _employmentController.text.trim(),
            _aboutController.text.trim(),
            profile,
            cover,
            _addressController.text.trim(),
            _homeTownController.text.trim(),
          );

          if(resultModel.error == false) {
            setState(() {
              _isLoading = false;
            });
            LoginApi();
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

  void LoginApi(){
    ConnectionUtils.checkConnection().then((intenet) async {
      if (intenet) {
        setState(() {
          _isLoading = true;
        });
        try{
          final LoginModel resultModel = await ApiManager.UserLogin(
              widget.mobile
          );

          if(resultModel.error == false) {
            setState(() {
              _isLoading = false;
            });

            SharedPreferences mPref = await SharedPreferences.getInstance();
            mPref.setString(Prefs.TOKEN, resultModel.token);
            mPref.setBool(Prefs.LOGIN, true);
            mPref.setString(Prefs.ID, resultModel.userId.toString());
            mPref.setString(Prefs.TYPE, resultModel.type);

            IntentUtils.fireIntentwithAnimations(context, UserBottomScreen(index: 0,), true);

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

  String? emailValidator(value) {
    if (value != null && !GetUtils.isEmail(value)) {
      return "Please enter valid email";
    } else {
      return null;
    }
  }

  Future<bool> _onBackPressed() async{
    Navigator.of(context).pop();
    return false;
  }
}
