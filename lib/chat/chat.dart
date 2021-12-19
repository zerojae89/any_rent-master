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
  bool _running = true;
  Stream<String> _clock() async* {
    // This loop will run forever because _running is always true
    while (_running) {
      print("_______________AAAAA");
      await Future<void>.delayed(Duration(seconds: 1));
      DateTime _now = DateTime.now();
      // This will be displayed on the screen as current time
      yield "${_now.hour} : ${_now.minute} : ${_now.second}";
    }
  }

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
    token = await customSharedPreferences.getString('token'); // 토큰 불러오기
    // debugPrint('Chat token == $token');
    state =  await customSharedPreferences.getBool('state'); // 현재 상태
    // debugPrint('Chat state == $state');
    setState(() { state = state; token = token;});
    try{
      if(state){
        String result = await chatServer.getChatList(token); //서버로부터 채팅 데이터 가져옴 (토큰 인증)
        String mbrUdResult = await myPageServer.getProfile(token); //서버에서 사용자정보 가져옴 (토큰 인증)
        Map<String, dynamic> profile = jsonDecode(mbrUdResult); //디코드로 JSON 내용 풀어 내용을 프로필과 비교
        chatItems = jsonDecode(result); //chatItems 로 받은 데이터를 jsonDecode 결과값으로 저장
        print('3333========$chatItems'); // 채팅 데이터가 올바르게 서버에서 내려졌는지 확인
        if(!isDisposed) { setState((){ chatItems = jsonDecode(result); mbrId = profile['mbrId']; }); } //데이터가 없을시 챗 아이템으로 받을 데이터를 jsonDecode 결과값으로 저장
        print('#############$chatItems');
        print('mbrId =============================22======== $mbrId');
      }
    } catch(e){
      globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.'))); // 에러발생시 해당 메시지 전달
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
                                  child:StreamBuilder(
                                    stream: _clock(),
                                    builder: (context, AsyncSnapshot<String> snapshot) {
                                      return ListView.builder(
                                          itemBuilder: (context, index) {
                                            return ChatItem(chatItems: chatItems[index]);
                                          },
                                          itemCount: chatItems.length
                                      );
                                    },
                                  )
                              )
                              // Expanded(
                              //   flex: 15,
                              //   child:
                              //   (chatItems.length == 0 ) ? // 데이터 없을 때 처리
                              //   Center(child:  roadChatList(chatItems)) :
                              //   ListView.builder(
                              //     itemCount: chatItems.length,
                              //     itemBuilder: (context, index) {
                              //       return ChatItem(chatItems: chatItems[index]);
                              //     },
                              //   ),
                              // )
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
