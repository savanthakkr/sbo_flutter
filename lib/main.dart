import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sbo/screens/bottom/user_bottom_screen.dart';
import 'package:sbo/screens/splash_screen.dart';
import 'package:sbo/utils/custom_color.dart';
import 'package:sbo/utils/firebase_services.dart';
import 'package:sbo/utils/intentutils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyCm5KubGZ74DvKp9bVSIbyjvJLvykN2Zo8",
          projectId: "sbonew-7a724",
          messagingSenderId: "802980808854",
          appId: "1:802980808854:android:d54e351a765b71a1d05ab7")
  );
  await FirebaseService.initializeFirebase();

  final RemoteMessage? _message = await FirebaseService.firebaseMessaging.getInitialMessage();
  if(_message != null) {
    // saveNotification(_message);
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp(message: _message));
}

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  String userId = "";

  if(message.data['userId'] == null){
    userId = "";
  } else {
    userId = message.data['userId'];
  }
  // InsertReportData(message.notification!.title!, message.notification!.body!,userId);
  // NotificationManager notificationManager = NotificationManager();
  // notificationManager.showNotificationWithNoBody(message);
}

class MyApp extends StatefulWidget {
  RemoteMessage? message;
  MyApp({super.key,required this.message});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(widget.message != null){
        Future.delayed(const Duration(milliseconds: 1000), () async {
          clickEvents(widget.message!);
        });
      }
    });
  }

  clickEvents(RemoteMessage message) {
    if(message.data['flag'] == "Request" || message.data['flag'] == "Update Status"){
      IntentUtils.fireIntentwithAnimations(context, UserBottomScreen(index: 1,), true);
    } else if(message.data['flag'] == "Save" || message.data['flag'] == "Share Requirement"){
      IntentUtils.fireIntentwithAnimations(context, UserBottomScreen(index: 2,), true);
    } else if(message.data['flag'] == "Group Add" || message.data['flag'] == "User"){
      IntentUtils.fireIntentwithAnimations(context, UserBottomScreen(index: 3,), true);
    } else {
      IntentUtils.fireIntentwithAnimations(context, UserBottomScreen(index: 0,), true);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    lockScreenPortrait();
    lockStatusBarColor();
    return StreamBuilder(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, AsyncSnapshot<ConnectivityResult> statusSnapshot) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          child: MaterialApp(
              locale: const Locale('en', 'US'),
              // translations: Language(),
              // fallbackLocale: const Locale('en', 'US'),
              theme: ThemeData(
                  primaryColor: CustomColor.primaryColor,
                  fontFamily: 'Poppins',
                  cardTheme: CardTheme(
                      surfaceTintColor: Colors.white,
                      color: Colors.white
                  ),
                  textSelectionTheme: TextSelectionThemeData(
                      cursorColor: CustomColor.primaryColor
                  )
              ),
              home:const SplashScreen(),
              title: 'sbo',
              // getPages: appRoute.getPages,
              debugShowCheckedModeBanner: false),
          builder: (context, widget) {
            ScreenUtil.init(context);
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: widget!,
            );
          },
        );
      },
    );
  }

  lockScreenPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void lockStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: CustomColor.whiteColor,
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.light,// For iOS (dark icons)
    ));
  }
}
