import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../settings/message_item.dart';
import '../settings/notification_data.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      title: 'AnyRent',
      theme: ThemeData( primarySwatch: Colors.purple, ), // 앱에 매인 테마 색을 정한다.
      // home: MyHomePage(index: 0),
      home :PushSampleApp(),
    );
  }
}


class PushSampleApp extends StatefulWidget {
  @override
  State createState() => _PushSampleAppState();
}

class _PushSampleAppState extends State<PushSampleApp> {
  var items = new List<ListItem>();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void initState() {
    super.initState();


    // class SendFCM{
    // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    // Future<void> configurFirevasesListeneners(BuildContext context){
    // _firebaseMessaging.configure(
    // onMessage: (Map<String, dynamic> message ) async{
    // print('onMessage ===========  $message');
    // },
    // onLaunch: (Map<String, dynamic> message ) async{
    // print('onMessage ===========  $message');
    // },
    // onResume: (Map<String, dynamic> message ) async{
    // print('onMessage ===========  $message');
    // },
    // );
    // }
    // }

    //sendFCM.configurFirevasesListeneners(context);
    // 위형식으로 클래스화 하여 메인에 서 호출 한다.
    // onMessage 처리 어떻게 할것인가?


    _firebaseMessaging.configure(
      //앱 실행 중일 경우  현재는 아이템에 띄워준다
      onMessage: (Map<String, dynamic> message) async {
        var notificationData = NotificationData.fromJson(message);
        print("onMessage: $message");
        //
        var newItem =
        new MessageItem(notificationData.title, notificationData.body);
        notifyNewItemInsert(newItem);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.getToken().then((String token) {
      print("token $token");
      sendTokenToServer(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Flutter Push Notification Sample';
    return MaterialApp(
        title: title,
        home: Scaffold(
            appBar: AppBar(title: Text(title)),
            body: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      "Received messages:",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _createList(items)
                ])));
  }


// 앱실 행시 앱 내용을 보여준다
  Widget _createList(List<ListItem> data) {
    return Expanded(
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return ListTile(
              title: item.buildTitle(context),
              subtitle: item.buildSubtitle(context),
            );
          },
        ));
  }

  void notifyNewItemInsert(ListItem newItem) {
    setState(() {
      items.insert(0, newItem);
    });
  }


  Future<String> sendTokenToServer(String token) async{
    print("getTown====================================================Start");
    http.Response response = await http.post( 'http://192.168.219.195/test',
        body: {
          "token" : token,
        }
    );
    if (response.statusCode == 200) {
      print("getTown====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      print('error!!!!!!!!!!');
      return "error";
    }
  }
}
