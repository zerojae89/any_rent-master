import 'dart:convert';

import 'package:any_rent/chat/chat_item.dart';
import 'package:any_rent/mypage/mypage_server.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:flutter/material.dart';
import '../login/login.dart';
import 'chat_server.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {

  String token, mbrId;
  bool state = true;
  final globalKey = GlobalKey<ScaffoldState>();
  bool isDisposed = false;
  List<dynamic> chatItems = [];

  @override
  void initState() {
    loadToken();
    super.initState();
  }
  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  loadToken() async{
    print('mbrId ===================================== $mbrId');
    token = await customSharedPreferences.getString('token');
    // debugPrint('Chat token == $token');
    state =  await customSharedPreferences.getBool('state');
    // debugPrint('Chat state == $state');
    setState(() { state = state; token = token;});
    try{
      if(state){
        String result = await chatServer.getChatList(token);
        // print('Chat1 chatRresult == $chatRresult');
        String mbrUdResult = await myPageServer.getProfile(token);
        Map<String, dynamic> profile = jsonDecode(mbrUdResult);
        chatItems = jsonDecode(result);
        if(!isDisposed) { setState((){ chatItems = jsonDecode(result); mbrId = profile['mbrId']; }); }
        print('mbrId ===================================== $mbrId');
      }
    } catch(e){
      globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // height = MediaQuery.of(context).size.height;
    // width = MediaQuery.of(context).size.width;
    return state ? Scaffold(
        key: globalKey,
        appBar: AppBar( centerTitle: true,  title: Text('메시지',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),), ),
        body: SafeArea(
          child: Stack(
            children: [ Positioned( left: 0, right: 0, top: 0, bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      )),
                  padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Column(
                    children: [
                      Expanded(
                          flex: 10,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 15,
                                child:
                                (chatItems.length == 0 ) ? // 데이터 없을 때 처리
                                Center(child:  roadChatList(chatItems)) :
                                ListView.builder(
                                  itemCount: chatItems.length,
                                  itemBuilder: (context, index) {
                                    return ChatItem(chatItems: chatItems[index]);
                                  },
                                ),
                              )
                            ],
                          )
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
    ): Login();
  }

  Widget roadChatList (List<dynamic> chatItems){
    if(chatItems.length == 0){
      return Center(child: Text('채팅 목록이 없습니다.'));
    } else {
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
      return CircularProgressIndicator();
    }
  }
}
