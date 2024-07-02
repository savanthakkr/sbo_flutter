import 'package:flutter/material.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/custom_style.dart';

class ShowImageScreen extends StatefulWidget {
  dynamic bytes;
  ShowImageScreen({super.key,required this.bytes});

  @override
  State<ShowImageScreen> createState() => _ShowImageScreenState();
}

class _ShowImageScreenState extends State<ShowImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "",
          style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.primaryColor,fontWeight: FontWeight.w700,fontSize: 18.0),
        ),
      ),
      body: Center(child: Image.memory(widget.bytes)),
    );
  }
}
