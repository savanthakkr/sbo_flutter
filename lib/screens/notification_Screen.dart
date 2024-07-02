import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbo/utils/assets.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/custom_style.dart';
import 'package:sbo/utils/size.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
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
            "Notification",
            style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.primaryColor,fontWeight: FontWeight.w700,fontSize: 18.0),
          ),
        ),
        body: _bodyWidget(),
      ),
    );
  }

  _bodyWidget(){
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: ListView.builder(
        itemBuilder: (context,index){
          return rawNotification(index);
        },
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: 5,
      ),
    );
  }

  rawNotification(index){
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 50.0,
                width: 50.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Image.asset(Assets.storyImageIcon).image)
                ),
              ),
              addHorizontalSpace(15.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "sbo Group",
                      style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w700,fontSize: 15.0),
                    ),
                    Text(
                      "Posted a new Requirement",
                      style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w400,fontSize: 12.0,color: CustomColor.greyColor),
                    )
                  ],
                ),
              ),
              addHorizontalSpace(5.0),
              index == 3 || index == 4 ? Container() : SvgPicture.asset(Assets.checkDoneIcon),
              index == 3 || index == 4 ? Container() : addHorizontalSpace(10.0),
              index == 3 || index == 4 ? Container() : SvgPicture.asset(Assets.deleteIcon),
              index == 4 ? SvgPicture.asset(Assets.connectPeopleIcon) : Container(),
            ],
          ),
          addVerticalSpace(5.0),
          Divider(
            color: Colors.grey.shade200,
            thickness: 1.5,
          ),
        ],
      ),
    );
  }

  Future<bool> _onBackPressed() async{
    Navigator.of(context).pop();
    return false;
  }
}
