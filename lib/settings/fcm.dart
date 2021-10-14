import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SendFCM{
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  Future<void> configurFirevasesListeneners(BuildContext context){
    firebaseMessaging.configure(
      // onMessage: (Map<String, dynamic> message ) async{
      //   print('onMessage ===========  $message');
      // },
      onLaunch: (Map<String, dynamic> message ) async{
        print('onMessage ===========  $message');
      },
      onResume: (Map<String, dynamic> message ) async{
        print('onMessage ===========  $message');
      },
    );
  }
}

SendFCM sendFCM = SendFCM();

//sendFCM.configurFirevasesListeneners(context);
// 위형식으로 클래스화 하여 메인에 서 호출 한다.
// onMessage 처리 어떻게 할것인가?