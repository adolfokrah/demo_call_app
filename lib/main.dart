import 'dart:async';

import 'package:callkeep/callkeep.dart';
import 'package:eraser/eraser.dart';
import 'package:flutter/material.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
final FlutterCallkeep _callKeep = FlutterCallkeep();
bool _callKeepInited = false;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  var payload = message.data;
  var callerId = payload['caller_id'] ;
  var callerName = payload['caller_name'] ;
  var uuid =payload['uuid'] ;
  var hasVideo = payload['has_video'] == "true";


  _callKeep.on(CallKeepPerformAnswerCallAction(),
          (CallKeepPerformAnswerCallAction event) {
         _callKeep.backToForeground();
         _callKeep.endAllCalls();
      });

  _callKeep.on(CallKeepPerformEndCallAction(),
          (CallKeepPerformEndCallAction event) {
        print('backgroundMessage: CallKeepPerformEndCallAction ${event.callUUID}');
      });

  if (!_callKeepInited) {
    _callKeep.setup(null, <String, dynamic>{
      'ios': {
        'appName': 'CallKeepDemo',
      },
      'android': {
        'alertTitle': 'Permissions required',
        'alertDescription':
        'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'ok',
        'additionalPermissions':[],
        'foregroundService': {
          'channelId': 'com.company.my',
          'channelName': 'Foreground service for my app',
          'notificationTitle': 'My app is running on background',
          'notificationIcon': 'Path to the resource icon of the notification',
        },
      },
    });
    _callKeepInited = true;
  }

  print('backgroundMessage: displayIncomingCall ($callerId)');
  _callKeep.displayIncomingCall(
      "023423352342342342343234", "0245301631",
      handleType: "number", hasVideo: false);
  Eraser.clearAllAppNotifications();
  Timer(const Duration(seconds: 30), () {
    _callKeep.endAllCalls();
  });

}



void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  late FirebaseMessaging messaging;
  final FlutterCallkeep _callKeep = FlutterCallkeep();
  bool _callKeepStarted = false;

  final callSetup = <String, dynamic>{
    'ios': {
      'appName': 'CallKeepDemo',
    },
    'android': {
      'alertTitle': 'Permissions required',
      'alertDescription':
      'This application needs to access your phone accounts',
      'cancelButton': 'Cancel',
      'okButton': 'ok',
      'additionalPermissions':[],
      // Required to get audio in background when using Android 11
      'foregroundService': {
        'channelId': 'com.ahil_call_app.call_app',
        'channelName': 'Foreground service for my app',
        'notificationTitle': 'My app is running on background',
        'notificationIcon': 'Path to the resource icon of the notification',
      },
    },
  };

  @override
  void initState(){
   initialiseFireBase();
   initializecallkeep();
    // TODO: implement initState
    super.initState();
  }

  initialiseFireBase()async{
    await Firebase.initializeApp();
    messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: false,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');
    getUserToken();
    listenToForegroundMessages();
  }
  getUserToken()async{
  // use the returned token to send messages to users from your custom server
    String? token = await messaging.getToken();
    print("Token: $token");
  }

  listenToForegroundMessages()async{
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        showIncomingCallScreen();
      }
    });
  }

  initializecallkeep(){
    _callKeep.setup(null, callSetup);
    _callKeep.on(CallKeepPerformAnswerCallAction(), answerAction);
    _callKeep.on(CallKeepPerformEndCallAction(), endAction);
  }

  Future<void> answerAction(CallKeepPerformAnswerCallAction event) async {
    final String? callUUID = event.callUUID;
    final String number = "0245301631";
    print('[answerCall] $callUUID, number: $number');
    endCall();

  }

  Future<void> endAction(CallKeepPerformEndCallAction event) async {
    print('call ended');
  }


  Future<void>showIncomingCallScreen()async{
    bool hasPhoneAccount = await _callKeep.hasPhoneAccount();
    if (!hasPhoneAccount) {
      hasPhoneAccount = await _callKeep.hasDefaultPhoneAccount(context, callSetup["android"]);
      print(hasPhoneAccount);
    }else {
      _callKeep.displayIncomingCall(
          "023423352342342342343234", "0245301631",
          handleType: "number", hasVideo: false);
      Timer(const Duration(seconds: 30), () {
       endCall();
      });
    }
  }


  Future<void>endCall()async{
    bool hasPhoneAccount = await _callKeep.hasPhoneAccount();
    if (!hasPhoneAccount) {
      return;
    }
    await _callKeep.endAllCalls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Call"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: MaterialButton(
          onPressed: (){
              //showIncomingCallScreen();
          },
          child: Text("Home Screen"),
        ),
      ),
    );
  }
}
