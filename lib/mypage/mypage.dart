import 'dart:convert';

import 'package:any_rent/settings/size_config.dart';
import 'package:flutter/material.dart';
import 'detail/bidding/mypage_bidding.dart';
import 'mypage_menu_item.dart';
import 'mypage_header.dart';
import 'package:any_rent/mypage/detail/block/mypage_block.dart';
import 'package:any_rent/mypage/detail/forum/mypage_forum.dart';
import 'package:any_rent/mypage/detail/keyword/mypage_keyword.dart';
import 'package:any_rent/mypage/detail/list/mypage_list.dart';
import 'package:any_rent/mypage/detail/mytown/mypage_mytown.dart';
import 'package:any_rent/mypage/detail/review/mypage_review.dart';
import '../login/login.dart';
import 'mypage_server.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';

class MyPage extends StatefulWidget {

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String token, mbrId, nicNm, prfSeq;
  bool state = true;
  bool isDisposed = false;
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  loadToken() async{
    token = await customSharedPreferences.getString('token'); // 서버에서 토큰 가져옴
    // debugPrint('Mypage token == $token');
    state =  await customSharedPreferences.getBool('state'); // 현재 로그인 상태 유,무 확인
    if(!isDisposed) setState(() => state); // 상태가 로그인이 아니면 로그인 하도록 함.
    print('Mypage state == $state');
  }

  @override
  Widget build(BuildContext context) {
    return state ? Scaffold(
          key: globalKey,
          appBar: AppBar(
            centerTitle: true,
            title: Text('마이페이지', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),

            // actions: <Widget>[
            //   IconButton(
            //       icon: Icon(Icons.settings),
            //       onPressed: (){
            //         debugPrint('설정');
            //       }
            //       ),
            // ],
          ),
           body : SingleChildScrollView(
             child: Column(
               children: [
                 Container(
                     decoration: BoxDecoration(
                       color: Colors.lightGreen,
                       borderRadius: BorderRadius.only(
                         bottomLeft: Radius.circular(140),
                         bottomRight: Radius.circular(140)
                       )
                         
                     ),
                     child: MyPageHeader()),
                 MyPageMenuItem( // 미리 짜여진 아이템 함수에 리턴할 값 작성
                   icon: Icon(Icons.location_on_outlined, color: Colors.black,),
                   title: '내동네',
                   press: (){
                     print('내 동네 이동');
                     Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageDetailMyTown(token: token,)));
                   },
                   vertical: 3,
                   horizontal: 2,
                 ),
                 MyPageMenuItem(
                   icon: Icon(Icons.article_outlined, color: Colors.black,),
                   title: '준일 / 한일 / 관심 / 키워드',
                   press: (){
                     print('준일 / 한일 / 관심 이동');
                     Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageDetailList(index: 0,)));
                   },
                   vertical: 3,
                   horizontal: 2,
                 ),
                 MyPageMenuItem(
                   icon: Icon(Icons.format_list_bulleted_outlined, color: Colors.black,),
                   title: '입찰 목록',
                   press: (){
                     print('입찰 목록 이동');
                     Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageBiddingList(index: 0,)));
                   },
                   vertical: 3,
                   horizontal: 2,
                 ),
                 MyPageMenuItem(
                   icon: Icon(Icons.attribution_outlined, color: Colors.black,),
                   title: '안전신호 & 후기',
                   press: (){
                     print('안전신호 & 후기 이동');
                     Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageReview(index: 0,)));
                   },
                   vertical: 3,
                   horizontal: 2,
                 ),
                 MyPageMenuItem(
                   icon: Icon(Icons.tag, color: Colors.black,),
                   title: '키워드',
                   press: (){
                     print('키워드 이동');
                     Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageDetailKeyword()));
                   },
                   vertical: 3,
                   horizontal: 2,
                 ),
                 MyPageMenuItem(
                   icon: Icon(Icons.highlight_off_sharp, color: Colors.black,),
                   title: '차단',
                   press: (){
                     print('차단 이동');
                     Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageDetailBlock()));
                   },
                   vertical: 3,
                   horizontal: 2,
                 ),
                 MyPageMenuItem(
                   icon: Icon(Icons.call_end_outlined, color: Colors.black,),
                   title: '고객센터',
                   press: (){
                     print('고객센터 이동');
                     Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageDetailForum()));
                   },
                   vertical: 3,
                   horizontal: 2,
                 ),
               ],
             ),
           )
      ) : Login();
  }
}
