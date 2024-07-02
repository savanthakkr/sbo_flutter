import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/custom_color.dart';
import '../../utils/dimensions.dart';

class PrimaryButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color? borderColor;
  final Color textColor;
  final double width;
  final double radius;
  final bool isLoading;
  final bool smallButton;

  const PrimaryButtonWidget({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width = 0,
    this.backgroundColor = CustomColor.primaryColor,
    this.textColor = CustomColor.whiteColor,
    this.radius = 8,
    this.isLoading = false,
    this.smallButton = false,
    this.borderColor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      width: width != 0 ? width : MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          elevation: 1,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(radius),
            ),
            side: borderColor!=null ? BorderSide(
              width: smallButton ? 1 : 2,
              color: borderColor!,
            ) : BorderSide.none,
          ),
        ),
        child: Center(
          child: isLoading ? CircularProgressIndicator(
            color: backgroundColor == CustomColor.primaryColor? CustomColor.backgroundColor : CustomColor.primaryColor,
          )
              : Text(
            text,
            textAlign: TextAlign.center,
            style: smallButton ? GoogleFonts.poppins(
              color: textColor,
              fontSize: Dimensions.smallestTextSize,
              fontWeight: FontWeight.w500,
            ) :
            GoogleFonts.poppins(
              color: textColor,
              fontSize: Dimensions.mediumTextSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
