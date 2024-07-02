import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/register_model.dart';
import 'package:sbo/screens/auth/otp_verify_screen.dart';
import 'package:sbo/screens/auth/select_profile_screen.dart';
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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  bool _isLoading = false;
  var formKey = GlobalKey<FormState>();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  TextEditingController _yearControllerto = TextEditingController();
  String ccodeNumber = "+91";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 20.0,
        leading: Container(),
        // leading: GestureDetector(
        //   onTap: (){
        //     Navigator.of(context).pop();
        //   },
        //   child: Padding(
        //     padding: const EdgeInsets.all(10.0),
        //     child: SvgPicture.asset(Assets.backIcon)),
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
              SvgPicture.asset(Assets.signupIcon),
              addVerticalSpace(5.0),
              Text(
                "Sign Up!",
                style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.primaryColor,fontWeight: FontWeight.w700,fontSize: 28.0),
              ),
              Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ut perspiciatis unde omnis iste natus.",
                style: CustomStyle.inputTextStyle.copyWith(fontSize: 14.0,fontWeight: FontWeight.w400,color: CustomColor.newhintColor),
                textAlign: TextAlign.justify,
              ),
              addVerticalSpace(50.0),
              _nameTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _yearTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _yearTextFieldEnd(),
              addVerticalSpace(Dimensions.marginSize),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: countrySelection(),
                  ),
                  addHorizontalSpace(5.0),
                  Expanded(
                    flex: 8,
                    child: _mobileTextField(),
                  ),
                ],
              ),
              addVerticalSpace(Dimensions.marginSize),
              GestureDetector(
                onTap: (){
                  // IntentUtils.fireIntentwithAnimations(context, OtpVerifyScreen(flag: "1",), false);
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
                      "Request OTP",
                      style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w800,fontSize: 14.0,color: CustomColor.whiteColor),
                    ),
                  ),
                ),
              ),
              addVerticalSpace(Dimensions.marginSize*1.1),
              GestureDetector(
                onTap: (){
                  Navigator.of(context).pop();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have account?",
                      style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w400,fontSize: 14.0,color: CustomColor.newhintColor),
                    ),
                    addHorizontalSpace(5.0),
                    Text(
                      "Sign In",
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

  countrySelection(){
    return GestureDetector(
      onTap: (){
        showCountryPicker(
          context: context,
          //Optional.  Can be used to exclude(remove) one ore more country from the countries list (optional).
          exclude: <String>['KN', 'MF'],
          favorite: <String>['IN'],
          //Optional. Shows phone code before the country name.
          showPhoneCode: true,
          onSelect: (Country country) {
            setState(() {
              ccodeNumber = "+"+country.phoneCode;
            });
          },
          // Optional. Sets the theme for the country list picker.
          countryListTheme: CountryListThemeData(
            // Optional. Sets the border radius for the bottomsheet.
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.0),
              topRight: Radius.circular(40.0),
            ),
            textStyle: CustomStyle.inputTextStyle,
            // Optional. Styles the search field.
            inputDecoration: InputDecoration(
              labelText: "Search",
              labelStyle: CustomStyle.inputTextStyle.copyWith(color: CustomColor.hintColor),
              hintText: "Search Country Code",
              hintStyle: CustomStyle.inputTextStyle.copyWith(color: CustomColor.hintColor),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: CustomColor.primaryColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: CustomColor.primaryColor,
                ),
              ),
            ),
            // Optional. Styles the text in the search field
            searchTextStyle: CustomStyle.inputTextStyle,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(color: CustomColor.borderColor,width: 1)
        ),
        padding: EdgeInsets.only(left: 10.0,top: 15.0,bottom: 15.0),
        child: Text(
            ccodeNumber
        ),
      ),
    );
  }

  _nameTextField() {
    return TextFormField(
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
    );
  }

  _yearTextField() {
    return TextFormField(
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
    );
  }

  _yearTextFieldEnd() {
    return TextFormField(
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
    );
  }

  _mobileTextField() {
    return TextFormField(
      controller: _mobileController,
      keyboardType: TextInputType.number,
      cursorColor: CustomColor.primaryColor,
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
      validator: phoneValidator,
    );
  }

  verify(){
    if(formKey.currentState!.validate()){
      // registerUser();

      IntentUtils.fireIntentwithAnimations(context, OtpVerifyScreen(
        flag: "1",
        type: "",
        id: "",
        token: "",
        ccode: ccodeNumber,
        mobile: _mobileController.text.trim(),
        name: _nameController.text.trim(),
        year: _yearController.text.trim(),
        yearTo: _yearControllerto.text.trim(),
      ), false);
    }
  }

  void registerUser() {
    ConnectionUtils.checkConnection().then((intenet) async {
      if (intenet) {
        setState(() {
          _isLoading = true;
        });
        try{
          final RegisterModel resultModel = await ApiManager.CreateUser(
              _nameController.text.trim(),
              _yearController.text.trim(),
              _yearControllerto.text.trim(),
              _mobileController.text.trim(),
          );

          if(resultModel.error == false) {
            setState(() {
              _isLoading = false;
            });

            IntentUtils.fireIntentwithAnimations(context, SelectProfileScreen(
              userId: resultModel.userId,
              year: _yearController.text.trim(),
              yearTo: _yearControllerto.text.trim(),
              mobile: _mobileController.text.trim(),
              name: _nameController.text.trim(),
              ccode: ccodeNumber,
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

  String? phoneValidator(value) {
    if (value != null && !GetUtils.isPhoneNumber(value)) {
      return "Enter valid mobile number";
    } else {
      return null;
    }
  }

}
