import 'dart:convert';

import 'package:any_rent/login/login.dart';
import 'package:any_rent/settings/fcm.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/home/home.dart';
import 'package:any_rent/register/register.dart';
import 'package:any_rent/chat/chat.dart';
import 'package:any_rent/mypage/mypage.dart';
import 'package:any_rent/permission/permission.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:any_rent/login/login_server.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.index}) : super(key: key);
  final int index;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  int _currentIndex;
  bool permission = true;
  String macAdr, token;

  @override
  void initState() {
    super.initState();
    loadToken();
    sendFCM.configurFirevasesListeneners(context);
    _currentIndex = widget.index;
  }

  List<Widget> _children = [Home(), Register(), Chat(), MyPage()]; // 하단메뉴를 list 화 시켜 집어 넣는다
  void _onTap(int index) { setState(() => _currentIndex = index ); } // 하단 네비게이션 바 인덱스 변경

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        body: permission ? _children[_currentIndex] : Permission(),
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            onTap: _onTap, //하단 네이게이션 페이지 이동
            currentIndex: _currentIndex, // 현제 페이지
            selectedItemColor: Colors.amber, // 선택된 색상
            unselectedItemColor: Colors.black, // 선택 안된 색상
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                title: Text('홈'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_comment_outlined),
                title: Text('등록'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message_outlined),
                title: Text('메시지'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_sharp),
                title: Text('마이페이지'),
              )
            ]
        ),
      ),
    );
  }

  Future<bool> onBackPressed(){ //뒤로가기 앱 종료
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))
          ),
          title: Text("앱을 종료 하시겠습니까?"),
          actions: <Widget>[
            FlatButton(
              child: Text("아니오"),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text("예"),
              onPressed: ()=>Navigator.pop(context, true),
            )
          ],
        )
    );
  }

  //사용자 인증 프로세스
  loadToken() async{
    permission = await customSharedPreferences.getBool('permission');
    setState(() => permission );
    debugPrint('loadToken permission ====================== $permission');
    token = await customSharedPreferences.getString('token');
    macAdr = await customSharedPreferences.getString('macAdr');
    debugPrint('token ======================= $token');
    debugPrint('macAdr ======================= $macAdr');
    if(token != null) { // token 있을시 서버에서 유효기간을 확인 받고 기간 만료시 재인증을 받는다.
      String result = await loginServer.sendToken(token);
      debugPrint('result ==== $result');
      Map<String, dynamic> user = jsonDecode(result);
      debugPrint('user === $user');
      String message = user['message'];
      debugPrint('message === $message');
      if(message == 'F'){
        await customSharedPreferences.remove('token');
        debugPrint('로그인으로 이동 토큰 삭제');
        return mainDialog();
      }
      if(message == 'N'){
        await customSharedPreferences.remove('token');
        debugPrint('토큰 재발급 업데이트 해야함');
        String value = user['token'];
        await customSharedPreferences.setString('token', value);
      }
      _firebaseMessaging.getToken().then((value) async { if(value != macAdr) { return mainDialog(); } }); //휴대폰 고유 맥주소 알아오기 및 토큰 맥주소와 사용중인 맥주소 다를 경우 재로그인 하기
    }
  }

  void mainDialog(){
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('재인증'),
            content: Text('재인증이 필요합니다. 로그인 페이지로 이동합니다.'),
            actions: [
              FlatButton(onPressed: () async{
                await customSharedPreferences.remove('macAdr'); //macAdr을 새로 저장하기 위하여 삭제
                Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
              }, child: Text('예')),
            ],
          );
        }
    );
  }
}
