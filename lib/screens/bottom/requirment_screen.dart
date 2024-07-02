import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbo/apis/api_manager.dart';
import 'package:sbo/models/requirment_model.dart';
import 'package:sbo/models/result_model.dart';
import 'package:sbo/screens/add_new_requirment_screen.dart';
import 'package:sbo/utils/assets.dart';
import 'package:sbo/utils/connection_utils.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/custom_style.dart';
import 'package:sbo/utils/intentutils.dart';
import 'package:sbo/utils/prefs.dart';
import 'package:sbo/utils/size.dart';
import 'package:sbo/utils/ui_utils.dart';
import 'package:sbo/widgets/circular_progressbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../edit_requirement_screen.dart';

class RequirementScreen extends StatefulWidget {
  const RequirementScreen({super.key});

  @override
  State<RequirementScreen> createState() => _RequirementScreenState();
}

class _RequirementScreenState extends State<RequirementScreen> {

  bool _isLoading = false;
  String? userId;
  List<AllRequirment> allReqirments = <AllRequirment>[];
  List<AllRequirment> activeReqirments = <AllRequirment>[];
  List<AllRequirment> complatedReqirments = <AllRequirment>[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefs();
  }

  getPrefs() async{
    SharedPreferences mPref = await SharedPreferences.getInstance();
    String? id = mPref.getString(Prefs.ID);

    setState(() {
      userId = id;
    });

    fetchAllRequirment();
    print(activeReqirments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? CircularProgressBar() : _bodyWidget(),
    );
  }

  _bodyWidget(){
    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        scrollDirection: Axis.vertical,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                addVerticalSpace(30.0),
                Container(
                  margin: const EdgeInsets.only(left: 15.0,right: 15.0,top: 20.0),
                  padding: const EdgeInsets.only(left: 20.0,right: 20.0,top: 10.0,bottom: 10.0),
                  height: 215.0,
                  decoration: BoxDecoration(
                      color: CustomColor.primaryColor,
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: SvgPicture.asset(Assets.requirmentIcon),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Total Requirement",
                                  style: CustomStyle.inputTextStyle.copyWith(color: Colors.white,fontSize: 12.0,fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  allReqirments.length.toString(),
                                  style: CustomStyle.inputTextStyle.copyWith(color: Colors.white,fontSize: 40.0,fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  "Completed Requirement",
                                  style: CustomStyle.inputTextStyle.copyWith(color: Colors.white,fontSize: 12.0,fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  complatedReqirments.length.toString(),
                                  style: CustomStyle.inputTextStyle.copyWith(color: Colors.white,fontSize: 40.0,fontWeight: FontWeight.w800),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      GestureDetector(
                        onTap: (){
                          // IntentUtils.fireIntentwithAnimations(context, AddNewRequirmentScreen(), false);
                          Navigator.of(context).push(PageRouteBuilder(

                            // transitionDuration: Duration(seconds: 2),
                            pageBuilder: (_, __, ___) {
                              return AddNewRequirmentScreen();
                            },
                          )
                          ).then((onValue){
                            fetchAllRequirment();
                          });
                        },
                        child: Container(
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(11.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(Assets.addUnfillIcon),
                              addHorizontalSpace(10.0),
                              Text(
                                "Add New Requirement",
                                style: CustomStyle.inputTextStyle.copyWith(color: CustomColor.primaryColor,fontWeight: FontWeight.w700,fontSize: 12.0),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20.0,right: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TabBar(
                          // splashBorderRadius: BorderRadius.circular(20),
                          indicatorSize: TabBarIndicatorSize.tab,
                          padding: const EdgeInsets.all(16),
                          tabAlignment: TabAlignment.fill,
                          dividerHeight: 0,
                          indicator: BoxDecoration(color: CustomColor.secondaryColor, borderRadius: BorderRadius.circular(9.0)),
                          labelStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: CustomColor.whiteColor,fontWeight: FontWeight.w600,fontSize: 14.0),
                          unselectedLabelColor: CustomColor.blackColor,
                          indicatorColor: CustomColor.secondaryColor,
                          unselectedLabelStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: CustomColor.blackColor,fontWeight: FontWeight.w600,fontSize: 14.0),
                          labelPadding: const EdgeInsets.symmetric(vertical: 4),
                          tabs: const [
                            Text("Active"),
                            Text("All"),
                          ],
                        ),
                      ),
                      SvgPicture.asset(Assets.filterIcon)
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
        body: Container(
          margin: const EdgeInsets.only(left: 15.0,right: 15.0,),
          child: TabBarView(
            children: [
              activeWidget(),
              allWidget(),
            ],
          ),
        ),
      ),
    );
  }

  activeWidget(){
    return ListView.builder(
      itemBuilder: (context,index){
        return rawActive(index);
      },
      itemCount: activeReqirments.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  rawActive(int index){
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                activeReqirments.elementAt(index).title,
                style: CustomStyle.inputTextStyle.copyWith(fontSize: 18.0,fontWeight: FontWeight.w600,color: CustomColor.blackColor),
              ),
            ),
            addHorizontalSpace(5.0),
            allReqirments.elementAt(index).status == "0" ?
              InkWell(
                onTap: (){
                  Navigator.of(context).push(PageRouteBuilder(

                    // transitionDuration: Duration(seconds: 2),
                    pageBuilder: (_, __, ___) {
                      return EditRequirementScreen(id: allReqirments.elementAt(index).id.toString());
                    },
                  )
                  ).then((onValue){
                    fetchAllRequirment();
                  });
                  // IntentUtils.fireIntentwithAnimations(context, EditRequirementScreen(id: allReqirments.elementAt(index).id.toString()), false);
                },

                child: SvgPicture.asset(Assets.editUserIcon),
              ) : Container(),
          ],
        ),
        SizedBox(height: 10,),
        Row(
          children: [
            Expanded(
              child: Text(
                activeReqirments.elementAt(index).description,
                style: CustomStyle.inputTextStyle.copyWith(fontSize: 15.0,fontWeight: FontWeight.w400,color: CustomColor.blackColor),
              ),
            ),
            addHorizontalSpace(5.0),
            InkWell(
              onTap: () async {
                print(allReqirments.elementAt(index).id);
                updateRequirementsStatus(allReqirments.elementAt(index).id.toString());
                print(allReqirments.elementAt(index).id);
                // Handle the result and update the UI accordingly
                // onDelete(index); // Call the callback to update the UI
              },
              child: SvgPicture.asset(Assets.checkDoneIcon),
            ),
            addHorizontalSpace(10.0),
            InkWell(
              onTap: () async {
                print(allReqirments.elementAt(index).id);
                deleteRequirements(allReqirments.elementAt(index).id.toString());
                print(allReqirments.elementAt(index).id);
                // Handle the result and update the UI accordingly
                // onDelete(index); // Call the callback to update the UI
              },
              child: SvgPicture.asset(Assets.deleteIcon),
            ),
          ],
        ),
        addVerticalSpace(5.0),
        Divider(
          color: Colors.grey.shade200,
          thickness: 1.5,
        ),
      ],
    );
  }

  allWidget(){
    return ListView.builder(
      itemBuilder: (context,index){
        return rawAll(index);
      },
      itemCount: allReqirments.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  rawAll(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                activeReqirments.elementAt(index).title,
                style: CustomStyle.inputTextStyle.copyWith(fontSize: 18.0,fontWeight: FontWeight.w600,color: CustomColor.blackColor),
              ),
            ),
            allReqirments.elementAt(index).status == "0" ?
            InkWell(
              onTap: (){
                Navigator.of(context).push(PageRouteBuilder(

                  // transitionDuration: Duration(seconds: 2),
                  pageBuilder: (_, __, ___) {
                    return EditRequirementScreen(id: allReqirments.elementAt(index).id.toString());
                  },
                )
                ).then((onValue){
                  fetchAllRequirment();
                });
                // IntentUtils.fireIntentwithAnimations(context, EditRequirementScreen(id: allReqirments.elementAt(index).id.toString()), false);
              },

              child: SvgPicture.asset(Assets.editUserIcon),
            ) : Container(),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                allReqirments.elementAt(index).description,
                style: CustomStyle.inputTextStyle.copyWith(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                  color: CustomColor.blackColor,
                ),
              ),
            ),

            addHorizontalSpace(5.0),
            if (allReqirments.elementAt(index).status == "0") ...[
              InkWell(
                onTap: () async {
                  print(allReqirments.elementAt(index).id);
                  updateRequirementsStatus(allReqirments.elementAt(index).id.toString());
                  print(allReqirments.elementAt(index).id);
                  // Handle the result and update the UI accordingly
                  // onDelete(index); // Call the callback to update the UI
                },
                child: SvgPicture.asset(Assets.checkDoneIcon),
              ),
              addHorizontalSpace(10.0),
              InkWell(
                onTap: () async {
                  print(allReqirments.elementAt(index).id);
                  deleteRequirements(allReqirments.elementAt(index).id.toString());
                  print(allReqirments.elementAt(index).id);
                  // Handle the result and update the UI accordingly
                  // onDelete(index); // Call the callback to update the UI
                },
                child: SvgPicture.asset(Assets.deleteIcon),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: CustomColor.primaryColor,
                ),
                child: Text(
                  "Completed",
                  style: CustomStyle.inputTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        addVerticalSpace(5.0),
        Divider(
          color: Colors.grey.shade200,
          thickness: 1.5,
        ),
      ],
    );
  }


  void deleteRequirements(String? requirementId) {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
        });
        try {
          final ResultModel resultModel = await ApiManager.DeleteRequirements(
              requirementId!
          );

          if (!resultModel.error) {
            setState(() {
              _isLoading = false;
            });

            // Show a success message
            UIUtils.bottomToast(context: context, text: resultModel.message, isError: false);

            fetchAllRequirment();

            // Optionally, call a function to refresh the parent screen
            // This depends on how your application is structured
            // For example, if you have a function in the parent widget to refresh the product list:
            // widget.parentWidget.refreshProducts();

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
        UIUtils.bottomToast(context: context, text: "Please check your internet connection", isError: true);
      }
    });
  }

  void updateRequirementsStatus(String? requirementId) {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
        });
        try {
          final ResultModel resultModel = await ApiManager.UpdateRequirementsStatus(
              requirementId!
          );

          if (!resultModel.error) {
            setState(() {
              _isLoading = false;
            });

            // Show a success message
            UIUtils.bottomToast(context: context, text: resultModel.message, isError: false);
            fetchAllRequirment();

            // Optionally, call a function to refresh the parent screen
            // This depends on how your application is structured
            // For example, if you have a function in the parent widget to refresh the product list:
            // widget.parentWidget.refreshProducts();

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
        UIUtils.bottomToast(context: context, text: "Please check your internet connection", isError: true);
      }
    });
  }


  void fetchAllRequirment() {
    ConnectionUtils.checkConnection().then((internet) async {
      if (internet) {
        setState(() {
          _isLoading = true;
          allReqirments.clear();
          activeReqirments.clear();
        });
        try {
          final RequirmentModel resultModel = await ApiManager.FetchUserRequirment(userId!);

          if (resultModel.error == false) {
            setState(() {
              _isLoading = false;
              allReqirments = resultModel.allRequirment;
            });

            for(int i=0;i<resultModel.allRequirment.length;i++){
              if(resultModel.allRequirment.elementAt(i).status == "0"){
                setState(() {
                  activeReqirments.add(resultModel.allRequirment.elementAt(i));
                });
              }
            }
            for(int i=0;i<resultModel.allRequirment.length;i++){
              if(resultModel.allRequirment.elementAt(i).status == "1"){
                setState(() {
                  complatedReqirments.add(resultModel.allRequirment.elementAt(i));
                });
              }
            }
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

}
