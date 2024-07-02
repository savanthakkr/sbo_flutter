import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'custom_color.dart';
import 'custom_style.dart';
import 'dimensions.dart';

class UIUtils{

  static bottomToast({required BuildContext context,required String text,required bool isError})
  {
    Fluttertoast.showToast(
      msg: text,
      backgroundColor: isError ? Colors.red : CustomColor.primaryColor,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      textColor: isError ? Colors.white : Colors.white,
    );
  }

  static var textinputPadding = const EdgeInsets.symmetric(vertical: 15,horizontal: 10);

  static OutlineInputBorder searchInputBorder = OutlineInputBorder(
    borderSide: const BorderSide(
      color: CustomColor.hintColor,
    ),
    borderRadius: BorderRadius.circular(Dimensions.radius),
  );

  static OutlineInputBorder textinputborder = OutlineInputBorder(
    borderSide: const BorderSide(
      color: CustomColor.borderColor,
      width: 1
    ),
    borderRadius: BorderRadius.circular(Dimensions.radius),
  );

  static OutlineInputBorder focusedBorder = OutlineInputBorder(
    borderSide: const BorderSide(
        color: CustomColor.primaryColor,
        width: 1
    ),
    borderRadius: BorderRadius.circular(Dimensions.radius),
  );

  static OutlineInputBorder errorBorder = OutlineInputBorder(
    borderSide: const BorderSide(
      color: Colors.red,
      width: 1
    ),
    borderRadius: BorderRadius.circular(Dimensions.radius),
  );

  static rounded_decoration({required Color color,required double radius,required Color borderColor})
  {
    return BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.all(Radius.circular(radius))
    );
  }

  static OutlineInputBorder searchinputborder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16.0),
    borderSide: const BorderSide(
      width: 0,
      color: CustomColor.searchbgColor
    )
  );

  // static notFountText({required String text}){
  //   return Center(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         //not_found.json
  //         // Lottie.asset('assets/lottie/not_found.json',
  //         //         height: 200,
  //         //         width: 200),
  //         Text(text,
  //           style: CustomStyle.notFoundTextStyle,),
  //       ],
  //     ),
  //   );
  // }
}