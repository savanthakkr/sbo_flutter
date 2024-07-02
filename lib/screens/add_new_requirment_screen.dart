import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/result_model.dart';
import 'package:sbo/utils/assets.dart';
import 'package:sbo/utils/connection_utils.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/custom_style.dart';
import 'package:sbo/utils/dimensions.dart';
import 'package:sbo/utils/prefs.dart';
import 'package:sbo/utils/size.dart';
import 'package:sbo/utils/ui_utils.dart';
import 'package:sbo/widgets/circular_progressbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as Io;

import 'package:sbo/utils/prefs.dart';

class AddNewRequirmentScreen extends StatefulWidget {
  const AddNewRequirmentScreen({super.key});

  @override
  State<AddNewRequirmentScreen> createState() => _AddNewRequirmentScreenState();
}

class _AddNewRequirmentScreenState extends State<AddNewRequirmentScreen> {

  bool _isLoading = false;
  var formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  String? userId;
  List<FilePickerResult?> multiimagepickerresult = <FilePickerResult?>[];
  List<String> imagebytes = <String>[];
  String? _radioValue;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefs();
  }


  getPrefs() async {
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String? id = mPref.getString(Prefs.ID);

    setState(() {
      userId = id!;
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
          titleSpacing: 0,
          leading: GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back_ios_rounded,color: CustomColor.primaryColor,),
          ),
          title: Text(
            "Add New Requirement",
            style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.primaryColor,fontWeight: FontWeight.w700,fontSize: 18.0),
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
              _titleTextField(),
              addVerticalSpace(Dimensions.marginSize),
              _descTextField(),
              addVerticalSpace(Dimensions.marginSize),
              imageWidget(),
              addVerticalSpace(Dimensions.marginSize),
              _radioButtons(),
              addVerticalSpace(Dimensions.marginSize * 2),
              GestureDetector(
                onTap: (){
                  if(formKey.currentState!.validate()){
                    if(imagebytes.isEmpty){
                      UIUtils.bottomToast(context: context, text: "Please select at-least one image", isError: true);
                    } else {
                      addRequirments();
                    }
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
                      "Publish",
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

  _titleTextField() {
    return TextFormField(
      controller: _titleController,
      keyboardType: TextInputType.text,
      cursorColor: CustomColor.primaryColor,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Add Title',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Add Title",
        hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
        // fillColor: CustomColor.editTextColor,
      ),
      style: CustomStyle.inputTextStyle,
      textAlign: TextAlign.start,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value){
        if(value!.isEmpty){
          return 'Enter valid title';
        }

        return null;
      },
    );
  }

  _radioButtons() {
    return Row(
      children: [
        Row(
          children: [
            Radio(
              value: 'Now',
              groupValue: _radioValue,
              onChanged: (value) {
                setState(() {
                  _radioValue = value as String;
                  print(_radioValue);
                });
              },
              activeColor: CustomColor.primaryColor,
            ),
            Text('Now'),
          ],
        ),
        SizedBox(width: 20), // add some space between the two radio buttons
        Row(
          children: [
            Radio(
              value: 'Letter',
              groupValue: _radioValue,
              onChanged: (value) {
                setState(() {
                  _radioValue = value as String;
                  print(_radioValue);
                });
              },

              activeColor: CustomColor.primaryColor,
            ),
            Text('Letter'),
          ],
        ),
      ],
    );
  }



  _descTextField() {
    return TextFormField(
      controller: _descController,
      keyboardType: TextInputType.multiline,
      cursorColor: CustomColor.primaryColor,
      maxLines: 5,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Add Description',
        labelStyle: CustomStyle.inputTextStyle.copyWith(fontSize: 16.0,fontWeight: FontWeight.w700,color: CustomColor.blackColor),
        border: UIUtils.textinputborder,
        contentPadding: UIUtils.textinputPadding,
        errorBorder: UIUtils.errorBorder,
        enabledBorder: UIUtils.textinputborder,
        focusedBorder: UIUtils.focusedBorder,
        filled: false,
        counterText: '',
        hintText: "Enter description (200 word max)",
        hintStyle: CustomStyle.hintTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w500),
        // fillColor: CustomColor.editTextColor,
      ),
      style: CustomStyle.inputTextStyle,
      textAlign: TextAlign.start,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value){
        if(value!.isEmpty){
          return 'Please enter description';
        }

        return null;
      },
    );
  }

  imageWidget(){
    return GestureDetector(
      onTap: checkPermission,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Images",
            style: CustomStyle.inputTextStyle.copyWith(fontSize: 12.0,fontWeight: FontWeight.w700),
          ),
          addVerticalSpace(5.0),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: CustomColor.lightgreyColor,width: 1.0)
            ),
            child: imagebytes.isNotEmpty ? SizedBox(
              height: 200,
              child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.widthSize,vertical: Dimensions.heightSize),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 120,
                      childAspectRatio: 1 / 1.3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemCount: imagebytes.length+1,
                  itemBuilder: (BuildContext ctx, index) {
                    if(index == imagebytes.length){
                      return DottedBorder(
                        borderType: BorderType.RRect,
                        dashPattern: const [5, 7],
                        radius: const Radius.circular(6.0),
                        color: CustomColor.secondaryColor,
                        strokeWidth: 1.5,
                        child: Container(
                          height: 110.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.0)
                          ),
                          child: Center(child: SvgPicture.asset(Assets.addImageIcon,color: CustomColor.secondaryColor,)),
                        ),
                      );
                    } else {
                      return rawImages(imagebytes[index]);
                    }
                  }),
            ) : DottedBorder(
                      borderType: BorderType.RRect,
                      dashPattern: const [5, 7],
                      radius: const Radius.circular(6.0),
                      color: CustomColor.secondaryColor,
                      strokeWidth: 1.5,
                      child: Container(
                        height: 110.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0)
                        ),
                        child: Center(child: SvgPicture.asset(Assets.addImageIcon,color: CustomColor.secondaryColor,)),
                    ),
                  ),
            // Row(
            //   children: [
            //     Expanded(
            //       flex: 1,
            //       child: DottedBorder(
            //         borderType: BorderType.RRect,
            //         dashPattern: const [5, 7],
            //         radius: const Radius.circular(6.0),
            //         color: CustomColor.secondaryColor,
            //         strokeWidth: 1.5,
            //         child: Container(
            //           height: 110.0,
            //           decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(6.0)
            //           ),
            //           child: Center(child: SvgPicture.asset(Assets.addImageIcon,color: CustomColor.secondaryColor,)),
            //         ),
            //       ),
            //     ),
            //     addHorizontalSpace(15.0),
            //     Expanded(
            //       flex: 1,
            //       child: DottedBorder(
            //         borderType: BorderType.RRect,
            //         dashPattern: const [5, 7],
            //         radius: const Radius.circular(6.0),
            //         color: CustomColor.secondaryColor,
            //         strokeWidth: 1.5,
            //         child: Container(
            //           height: 110.0,
            //           decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(6.0)
            //           ),
            //           child: Center(child: SvgPicture.asset(Assets.addImageIcon,color: CustomColor.secondaryColor,)),
            //         ),
            //       ),
            //     ),
            //     addHorizontalSpace(15.0),
            //     Expanded(
            //       flex: 1,
            //       child: DottedBorder(
            //         borderType: BorderType.RRect,
            //         dashPattern: const [5, 7],
            //         radius: const Radius.circular(6.0),
            //         color: CustomColor.secondaryColor,
            //         strokeWidth: 1.5,
            //         child: Container(
            //           height: 110.0,
            //           decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(6.0)
            //           ),
            //           child: Center(child: SvgPicture.asset(Assets.addImageIcon,color: CustomColor.secondaryColor,)),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          )
        ],
      ),
    );
  }

  rawImages(String bytes){
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: Image.memory(base64Decode(bytes),fit: BoxFit.cover,).image
        ),
      ),
    );
  }

  checkPermission() async{
    if (Io.Platform.isAndroid) {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      debugPrint('MY_SDK : ${androidInfo.version.sdkInt}');
      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.photos.request();
        // final status2 = await Permission.camera.request();
        if (status == PermissionStatus.granted) {
          print('Permission granted.');
          openMultiImagePicker();
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
          openMultiImagePicker();
        } else if (status == PermissionStatus.denied) {
          print(
              'Permission denied. Show a dialog and again ask for the permission');
          await Permission.storage.shouldShowRequestRationale;
        }
      }
    }
  }

  openMultiImagePicker() async {
    multiimagepickerresult.clear();
    imagebytes.clear();
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image,allowMultiple: true);

    if (result != null) {
      for(int i=0;i<result.files.length;i++){
        setState(() {
          multiimagepickerresult.add(result);
          // bytesFromPicker = imagepickerresult!.files.first.bytes;
          // imageVariable = MemoryImage(bytesFromPicker!);
          print("file Size ${multiimagepickerresult.length}");
          String fileName = result.files.elementAt(i).name;
          print("fileName ${fileName}");

          String? filePath = result.files.elementAt(i).path;
          final bytes = Io.File(filePath!).readAsBytesSync();
          imagebytes.add(base64Encode(bytes));
        });
      }
    } else {

    }

    setState(() {});
    print("Length ${imagebytes.length}");
  }

  void addRequirments() {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
        });
        try {
          final ResultModel resultModel = await ApiManager.AddRequirements(
              userId!,
              _titleController.text.trim(),
              _descController.text.trim(),
              imagebytes,
              _radioValue!,
          );

          if (resultModel.error == false) {
            setState(() {
              _isLoading = false;
              _titleController.text = "";
              _descController.text = "";
              multiimagepickerresult.clear();
              imagebytes.clear();
            });
            Navigator.of(context).pop();
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

  Future<bool> _onBackPressed() async{
    Navigator.of(context).pop();
    return false;
  }
}
