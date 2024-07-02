import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_share/flutter_share.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher.dart';

class IntentUtils{

  // static void OpenBrowser(String url) {
  //   // _launchURL(String url) async {
  //   String url1 = url;
  //   if (canLaunch(url1) != null) {
  //     launch(url1);
  //   } else {
  //     throw 'Could not launch $url1';
  //   }
  //   // }
  // }

  // _launchURL(String url) async {
  //   String url1 = url;
  //   if (await canLaunch(url1)) {
  //     launch(url1);
  //   } else {
  //     throw 'Could not launch $url1';
  //   }
  // }

  // static Future<void> share_app(BuildContext context) async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   if(Platform.isIOS){
  //     //todo
  //   }
  //   else {
  //     FlutterShare.share(title:'share app',linkUrl: "https://play.google.com/store/apps/details?id=" + packageInfo.packageName);
  //   }
  // }

  // static Future<void> share_data(BuildContext context,String text) async {
  //   if(Platform.isIOS){
  //     //todo
  //   }
  //   else {
  //     FlutterShare.share(title:'share login information',
  //         text: text);
  //   }
  // }

  static void fireIntent(BuildContext context, dynamic classobj) {

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => classobj),
          (Route<dynamic> route) => false,
    );
    // Navigator.of(context).pushReplacement(MaterialPageRoute(
    //     builder: (BuildContext c) => classobj));
  }

  static void fireIntentwithoutFinish(BuildContext context, dynamic classobj)
  {
    Navigator.of(context).push(MaterialPageRoute<dynamic>(
      builder: (BuildContext context) {
        return classobj;
      },
    )
    );
  }

  static void fireIntentwithAnimations(BuildContext context, dynamic classobj,bool finishall)
  {
    if(finishall)
    {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        // transitionDuration: Duration(seconds: 2),
          pageBuilder: (_, __, ___) => classobj));
    }
    else{
      Navigator.of(context).push(PageRouteBuilder(
        // transitionDuration: Duration(seconds: 2),
        pageBuilder: (_, __, ___) {
          return classobj;
        },
      )
      );
    }
  }

  // static void openWhatsapp(BuildContext context, String number,String text) {
  //         // String url = "https://api.whatsapp.com/send?phone="+number;
  //         var whatsappURl_android = "whatsapp://send?phone=" + number + "&text="+text;
  //         var whatappURL_ios = "https://wa.me/$number?text=${Uri.parse("$text")}";
  //         if (Platform.isIOS) {
  //           // for iOS phone only
  //           if (canLaunch(whatappURL_ios) != null) {
  //             launch(whatappURL_ios, forceSafariVC: false);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: new Text("whatsapp no installed")));
  //     }
  //   }
  //   else {
  //     // android , web
  //     if (canLaunch(whatsappURl_android) != null) {
  //       launch(whatsappURl_android);
  //     }
  //     else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: new Text("whatsapp no installed")));
  //     }
  //   }
  // }
  //
  // static void makePhoneCall(BuildContext context, String callNo) {
  //
  //   var url = "tel:"+callNo;
  //   if (canLaunch(url)!=null) {
  //     launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }
}