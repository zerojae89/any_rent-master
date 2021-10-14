import 'package:flutter/material.dart';
import '../mypage_detail_appbar.dart';
import 'forum_menu_item.dart';

class MyPageDetailForum extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MyPageDetailAppbar( title: '고객센터',),
          MyPageMenuItem(
            icon: Icon(Icons.info_outline, color: Colors.lightGreen[400],),
            title: '서비스 소개',
            press: (){
              print('서비스 소개');
            },
            vertical: 2,
            horizontal: 1,
          ),
          MyPageMenuItem(
            icon: Icon(Icons.perm_identity, color: Colors.lightGreen[400],),
            title: '이용안내',
            press: (){
              print('이용안내');
            },
            vertical: 2,
            horizontal: 1,
          ),
          MyPageMenuItem(
            icon: Icon(Icons.account_balance_outlined, color: Colors.lightGreen[400],),
            title: '이용약관',
            press: (){
              print('이용약관');
            },
            vertical: 2,
            horizontal: 1,
          ),
          MyPageMenuItem(
            icon: Icon(Icons.admin_panel_settings_outlined, color:Colors.lightGreen[400]),
            title: '개인정보취급방침',
            press: (){
              print('개인정보취급방침');
            },
            vertical: 2,
            horizontal: 1,
          ),
          MyPageMenuItem(
            icon: Icon(Icons.add_comment_outlined, color: Colors.lightGreen[400],),
            title: '자주묻는 질문',
            press: (){
              print('자주묻는 질문');
            },
            vertical: 2,
            horizontal: 1,
          ),
          MyPageMenuItem(
            icon: Icon(Icons.mail_outline, color: Colors.lightGreen[400]),
            title: '문의하기',
            press: (){
              print('문의하기');
            },
            vertical: 2,
            horizontal: 1,
          ),
        ],
      ),
    );
  }
}


//
//
//
//
//