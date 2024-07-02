import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/result_model.dart';
import 'package:sbo/screens/auth/business_profile_screen.dart';
import 'package:sbo/utils/assets.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/custom_style.dart';
import 'package:sbo/utils/intentutils.dart';
import 'package:sbo/utils/size.dart';
import 'package:sbo/utils/ui_utils.dart';

import '../utils/connection_utils.dart';

class SubscriptionPlanScreen extends StatefulWidget {

  int userId;
  String mobile,year,name,ccode;

  SubscriptionPlanScreen({super.key,required this.userId,required this.mobile,required this.year,required this.name,required this.ccode});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  String _selectedPlan = "";
  bool _isLoading = false;

  void _selectPlan(String plan) {
    setState(() {
      _selectedPlan = plan;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Subscription Plan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SubscriptionPlanCard(
              title: 'Silver',
              price: '\u{20B9} 5555/year',
              content: 'Free Listing\nLogo Image\n10/Month Connection Request\nView User Profile\nPersonal & Group chat with connections.\nPosting a Requirements\n5Product / Service Upload\nPaid Advertising\nPaid Business Meetings',
              isSelected: _selectedPlan == 'Silver',
              onSelect: () => _selectPlan('Silver'),
            ),
            SubscriptionPlanCard(
              title: 'Gold',
              price: '\u{20B9} 11111/year',
              content: 'Free Listing\nProfile Image\nLogo Image\nUnlimited Connection Request\nView User Profile\nPersonal & Group chat with all app users.\nPosting a Requirements\n25 Product / Service Upload\n5 days/Month Advertising\n1/Year Business Meetings',
              isSelected: _selectedPlan == 'Gold',
              onSelect: () => _selectPlan('Gold'),
            ),
            SubscriptionPlanCard(
              title: 'Platinum',
              price: '\u{20B9} 22222/year',
              content: 'Free Listing\nProfile Image\nLogo Image\nUnlimited Connection Request\nView User Profile\nPersonal & Group chat with all app users.\nPosting a Requirements\nUnlimited Product / Service Upload\n10 days/Month Advertising\n2/Year Business Meetings',
              isSelected: _selectedPlan == 'Platinum',
              onSelect: () => _selectPlan('Platinum'),
            ),
            addVerticalSpace(20),
            GestureDetector(
              onTap: (){
                if(_selectedPlan == "Platinum"){
                  UIUtils.bottomToast(context: context, text: "This plan is coming soon...", isError: true);
                } else {
                  UpdateType();
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
                    "Purchase",
                    style: CustomStyle.inputTextStyle.copyWith(fontWeight: FontWeight.w800,fontSize: 14.0,color: CustomColor.whiteColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void UpdateType() {
    ConnectionUtils.checkConnection().then((intenet) async {
      if (intenet) {
        setState(() {
          _isLoading = true;
        });
        try{


          final ResultModel resultModel = await ApiManager.UpdateUserSubscription(
              widget.userId,
            _selectedPlan,
          );

          if(resultModel.error == false) {
            setState(() {
              _isLoading = false;
            });

            IntentUtils.fireIntentwithAnimations(context, BusinessProfileScreen(
              userId: widget.userId,
              year: widget.year,
              mobile: widget.mobile,
              name: widget.name,
              ccode: widget.ccode,
              selectedPlan: _selectedPlan,
            ), false);
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
}

class SubscriptionPlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String content;
  final bool isSelected;
  final VoidCallback onSelect;

  SubscriptionPlanCard({
    required this.title,
    required this.price,
    required this.content,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: isSelected ? CustomColor.primaryColor : CustomColor.whiteColor,
        ),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(10),
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,style: CustomStyle.inputTextStyle.copyWith(color: isSelected ? CustomColor.whiteColor : CustomColor.blackColor,fontSize: 14,fontWeight: FontWeight.w600),),
                      addVerticalSpace(10.0),
                      Text(price,style: CustomStyle.inputTextStyle.copyWith(color: isSelected ? CustomColor.whiteColor : CustomColor.blackColor,fontSize: 14,fontWeight: FontWeight.w500),)
                    ],
                  ),
                ),
                SvgPicture.asset(
                    isSelected ? Assets.selectIcon : Assets.unselectIcon
                ),
              ],
            ),
            isSelected ? addVerticalSpace(10.0) : Container(),
            isSelected ? Column(
              children: [
                Text(content,style: CustomStyle.inputTextStyle.copyWith(color: isSelected ? CustomColor.whiteColor : CustomColor.blackColor,fontSize: 14,fontWeight: FontWeight.w500),),
              ],
            ) : Container(),
          ],
        )
      ),
    );
  }
}
