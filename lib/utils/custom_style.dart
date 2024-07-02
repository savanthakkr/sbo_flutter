import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_color.dart';
import 'dimensions.dart';

class CustomStyle {
  //auth screens
  static var onboardingTitleStyle = GoogleFonts.poppins(
    color: CustomColor.blackColor,
    fontSize: Dimensions.largeTextSize,
    fontWeight: FontWeight.w500,
  );

  static var titleTextStyle = GoogleFonts.poppins(
    color: CustomColor.blackColor,
    fontSize: Dimensions.mediumTextSize,
    fontWeight: FontWeight.w400,
  );

  static var extraLargeStyle = GoogleFonts.poppins(
    color: CustomColor.primaryColor,
    fontSize: Dimensions.regularTextSize,
    fontWeight: FontWeight.w700,
  );

  static var appbarTextTitleWhite = GoogleFonts.poppins(
    color: CustomColor.whiteColor,
    fontSize: Dimensions.mediumTextSize,
    fontWeight: FontWeight.w500,
  );

  static var appbarTextTitleDark = GoogleFonts.poppins(
    color: CustomColor.blackColor,
    fontSize: Dimensions.mediumTextSize,
    fontWeight: FontWeight.w500,
  );

  static var primarySmallTitle = GoogleFonts.poppins(
    color: CustomColor.primaryColor,
    fontSize: Dimensions.smallTextSize,
    fontWeight: FontWeight.w500,
  );

  static var smallHeadingTextStyle = GoogleFonts.poppins(
    color: CustomColor.labelColor,
    fontSize: Dimensions.smallestTextSize,
    fontWeight: FontWeight.w500,
  );

  static var regularLightTextStyle = GoogleFonts.poppins(
    color: CustomColor.hintColor,
    fontSize: Dimensions.smallestTextSize,
    fontWeight: FontWeight.w400,
  );

  static var inputTextStyle = GoogleFonts.poppins(
    color: Colors.black,
    fontSize: Dimensions.regularTextSize,
    fontWeight: FontWeight.w500,
  );

  static var buttonTextStyle = GoogleFonts.poppins(
    color: CustomColor.backgroundColor,
    fontSize: Dimensions.mediumTextSize,
    fontWeight: FontWeight.w500,
  );

  static var whiteSemiBoldTextStyle = GoogleFonts.poppins(
    color: CustomColor.whiteColor,
    fontSize: Dimensions.regularTextSize,
    fontWeight: FontWeight.w500,
  );

  static var blackSemiBoldTextStyle = GoogleFonts.poppins(
    color: CustomColor.blackColor,
    fontSize: Dimensions.regularTextSize,
    fontWeight: FontWeight.w500,
  );

  static var whiteListItemTextStyle = GoogleFonts.poppins(
    color: CustomColor.whiteColor,
    fontSize: Dimensions.mediumTextSize,
    fontWeight: FontWeight.w400,
  );

  static var mediumTextStyle = GoogleFonts.poppins(
    color: CustomColor.blackColor,
    fontSize: Dimensions.regularTextSize,
    fontWeight: FontWeight.w400,
  );

  static var blackPoppins = GoogleFonts.poppins(
    color: CustomColor.blackColor,
    fontSize: Dimensions.regularTextSize,
    fontWeight: FontWeight.w500,
  );

  static var redPoppins = GoogleFonts.poppins(
    color: CustomColor.redTextColor,
    fontSize: Dimensions.regularTextSize,
    fontWeight: FontWeight.w500,
  );

  static var smallSemiBoldTextStyle = GoogleFonts.poppins(
    color: CustomColor.blackColor,
    fontSize: Dimensions.smallestTextSize,
    fontWeight: FontWeight.w500,
  );

  static var hintTextStyle = GoogleFonts.poppins(
    color: CustomColor.hintColor,
    fontSize: Dimensions.smallestTextSize,
    fontWeight: FontWeight.w400,
  );
}
