import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

class BusinessProfileScreen extends StatefulWidget {

  int userId;
  String mobile,year,name,ccode, selectedPlan;

  BusinessProfileScreen({super.key,required this.userId,required this.mobile,required this.selectedPlan,required this.year,required this.name,required this.ccode});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {

  var formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _bnameController = TextEditingController();
  TextEditingController _homeTownController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _cityTextFieldController = TextEditingController();
  TextEditingController _stateTextFieldController = TextEditingController();
  TextEditingController _pincodeController = TextEditingController();
  TextEditingController _addressController2 = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _aboutController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();

  String? bType,bCat;
  String? profileImgurl,coverImage;

  List<String> Product = [
    "Consumer Electronics",
    "Apparel and Accessories",
    "Home and Kitchen Appliances",
    "Furniture and Home Decor",
    "Beauty and Personal Care Products",
    "Toys and Games",
    "Sports and Outdoor Equipment",
    "Books and Stationery",
    "Food and Beverages",
    "Health and Wellness Products",
    "Automotive Parts and Accessories",
    "Jewelry and Watches",
    "Pet Supplies",
    "Gardening and Outdoor Supplies",
    "Tools and Home Improvement",
    "Baby and Kids Products",
    "Office Supplies",
    "Musical Instruments",
    "Software and Applications",
    "Art and Craft Supplies" ,
  ];


  List<String> Service = [
    "Healthcare Services",
    "Financial Services",
    "Education and Tutoring",
    "Legal Services",
    "Consulting Services",
    "Marketing and Advertising",
    "IT and Software Development",
    "Event Planning and Management",
    "Travel and Tourism Services",
    "Real Estate Services",
    "Cleaning Services"
    "Maintenance Services",
    "Transportation and Logistics",
    "Personal Care Services",
    "Renovation Services",
     "Food Services",
     "Personal Training",
    "Childcare Services",
    "Pet Care Services",
    "Photography and Videography",
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData(){
    setState(() {
      _mobileController.text = widget.ccode+" "+widget.mobile;
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
            "Business Profile",
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
                          widget.selectedPlan == "Gold" ? checkPermission(false) : UIUtils.bottomToast(context: context, text: "You Have a Selected Silver Plan", isError: true);
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
              _bnameTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _nameTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _mobileTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _emailTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _typeDropdownInput(),
              addVerticalSpace(Dimensions.marginSize),
              _categoryDropdownInput(),
              // _categoryTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _aboutTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _addressTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _addressTextField2(),
              addVerticalSpace(Dimensions.marginSize),
              _stateTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _cityTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _pinCodeTextField(),
              addVerticalSpace(Dimensions.marginSize),
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

  _bnameTextField() {
    return TextFormField(
      controller: _bnameController,
      keyboardType: TextInputType.text,
      cursorColor: CustomColor.primaryColor,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Business Name',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Business Name",
        hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
        // fillColor: CustomColor.editTextColor,
      ),
      style: CustomStyle.inputTextStyle,
      textAlign: TextAlign.start,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value){
        if(value!.isEmpty || value.length < 3){
          return 'Enter valid business name';
        }

        return null;
      },
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
        labelText: 'Owner Name',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Owner Name",
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

  _aboutTextField() {
    return TextFormField(
      controller: _aboutController,
      keyboardType: TextInputType.multiline,
      cursorColor: CustomColor.primaryColor,
      maxLines: 5,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Business Description',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Enter business description (max 100 word)",
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
  _pinCodeTextField() {
    return TextFormField(
      controller: _pincodeController,
      keyboardType: TextInputType.number,
      cursorColor: CustomColor.primaryColor,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Pin Code',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Pin Code",
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
        labelText: 'Business Address',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Enter business Address (max 100 word)",
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

  _addressTextField2() {
    return TextFormField(
      controller: _addressController2,
      keyboardType: TextInputType.multiline,
      cursorColor: CustomColor.primaryColor,
      maxLines: 3,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Business Address 2',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Enter business Address 2 (max 100 word)",
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

  _stateTextField() {
    return TextFormField(
      controller: _stateTextFieldController,
      keyboardType: TextInputType.multiline,
      cursorColor: CustomColor.primaryColor,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Business State',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Enter business State ",
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
  _cityTextField() {
    return TextFormField(
      controller: _cityTextFieldController,
      keyboardType: TextInputType.multiline,
      cursorColor: CustomColor.primaryColor,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Business City',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Enter business City ",
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

  _typeDropdownInput(){
    return Container(
      child: DropdownSearch<String>(
        // mode: Mode.DIALOG,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Select Business Type",
            hintText: 'Select Business Type',

            hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
            contentPadding: UIUtils.textinputPadding,
            labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
            errorBorder: UIUtils.errorBorder,
            enabledBorder: UIUtils.textinputborder,
            focusedBorder: UIUtils.focusedBorder,
            border: UIUtils.textinputborder,
            disabledBorder: UIUtils.textinputborder,
          ),
        ),
        items: [
          "Service",
          "Product",
        ],
        itemAsString: (String? u) => u!,
        validator: (value) {
          if (value == null || value == '') {
            return 'Please select Business Type';
          }
          return null;
        },
        onChanged: (String? data){
          setState(() {
            bType = data;
          });
        },
      ),
    );
  }

  _categoryTextField() {
    return TextFormField(
      controller: _categoryController,
      keyboardType: TextInputType.multiline,
      cursorColor: CustomColor.primaryColor,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Business Category',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        hintText: "Enter Business Category",
        hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
        // fillColor: CustomColor.editTextColor,
      ),
      style: CustomStyle.inputTextStyle,
      textAlign: TextAlign.start,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value){
        if(value!.isEmpty){
          return 'Please enter your business category';
        }

        return null;
      },
    );
  }

  _categoryDropdownInput(){
    return Container(
      child: DropdownSearch<String>(
        // mode: Mode.DIALOG,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Select Category",
            hintText: 'Select Category',
            hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
            contentPadding: UIUtils.textinputPadding,
            labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
            errorBorder: UIUtils.errorBorder,
            enabledBorder: UIUtils.textinputborder,
            focusedBorder: UIUtils.focusedBorder,
            border: UIUtils.textinputborder,
            disabledBorder: UIUtils.textinputborder,
          ),
        ),
        items: bType == "Product" ? Product : Service,
        itemAsString: (String? u) => u!,
        validator: (value) {
          if (value == null || value == '') {
            return 'Please select Category';
          }
          return null;
        },
        onChanged: (String? data){
          setState(() {
            bCat = data;
          });
        },
      ),
    );
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

  void registerUser(String profile,String cover) {
    ConnectionUtils.checkConnection().then((intenet) async {
      if (intenet) {
        setState(() {
          _isLoading = true;
        });
        try{
          final ResultModel resultModel = await ApiManager.CreateBusinessProfile(
              widget.userId.toString(),
              _emailController.text.trim(),
              _bnameController.text.trim(),
              bType!,
              bCat!,
              _aboutController.text.trim(),
            profile,
            cover,
            _addressController.text.trim(),
              _addressController2.text.trim(),
              _stateTextFieldController.text.trim(),
              _cityTextFieldController.text.trim(),
              _pincodeController.text.trim(),
              _homeTownController.text.trim()
          );

          UIUtils.bottomToast(context: context, text: resultModel.message, isError: false);


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
