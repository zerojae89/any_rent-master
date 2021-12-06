import 'dart:convert';

import 'package:any_rent/settings/size_config.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/main_home.dart';
import 'package:flutter/rendering.dart';
import '../mypage_menu_item.dart';
import 'mypage_profile_menu_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mypage_profile_nicname.dart';
import 'mypage_profile_header.dart';
import '../mypage_server.dart';
import '../../login/login_server.dart';

class MyPageProfile extends StatefulWidget{
  @override
  _MyPageProfileState createState() => _MyPageProfileState();
}

class _MyPageProfileState extends State<MyPageProfile> {
  SharedPreferences _prefs;
  String token, result, mbrId, nicNm, cpNo, prfSeq,cpNo1;
  double defaultSize = SizeConfig.defaultSize;



  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  _loadToken() async{
    RegExp phone = RegExp(r'(\d{3})(\d{3,4})(\d{4})');
    _prefs = await SharedPreferences.getInstance();
    token = _prefs.getString('token');
    result = await myPageServer.getProfile(token);
    Map<String, dynamic> profile = jsonDecode(result);
    print('profile ==================== $profile');
    setState(() {
      mbrId = profile['mbrId'];
      nicNm = profile['nicNm'];
      cpNo1 = profile['cpNo'];
      prfSeq = profile['prfSeq'].toString();
      var matches = phone.allMatches(cpNo1);
      var match = matches.elementAt(0);
      cpNo = '${match.group(1)}-${match.group(2)}-${match.group(3)}';
      print(cpNo);
    });
  }




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('내 프로필'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => MyHomePage(index: 3,)), (route) => false)
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                MyPageProfileHeader(),
                MyPageProfileNicName(
                  title: nicNm,
                  icon: Icon(Icons.perm_identity_outlined , color: Colors.black,),
                  vertical: 3,
                  horizontal: 2,
                  token: token,
                ),
                SizedBox(height: 8,),
                MypageProfileMenuItem(
                  icon: Icon(Icons.call, color: Colors.black,),
                  title: '전화번호',
                  contents: cpNo,
                  vertical: 3,
                  horizontal: 2,
                ),
                MypageProfileMenuItem(
                  icon: Icon(Icons.home_outlined, color: Colors.black,),
                  title: '주소',
                  contents: '서울시 서초구 강남대로 40-13',
                  vertical: 3,
                  horizontal: 2,
                ),
                SizedBox(height: 5,),
                MypageProfileMenuItem(
                  icon: Icon(Icons.mood_outlined, color: Colors.black,),
                  title: '아이디',
                  contents: mbrId,
                  vertical: 3,
                  horizontal: 2,
                ),

                // MyPageMenuItem(
                //   icon: Icon(Icons.monetization_on_rounded, color: Colors.purple,),
                //   title: '계좌 인증 & 확인',
                //   press: (){
                //     print('계좌 인증 & 확인');
                //     // Navigator.push(context, MaterialPageRoute(builder: (context) => MypageDetailMytown()));
                //   },
                //   vertical: 3,
                //   horizontal: 2,
                // ),
                SizedBox(height:17,),
                MyPageMenuItem(
                  icon: Icon(Icons.logout, color: Colors.black,),
                  title: '로그아웃',
                  press: logoutDialog,
                  vertical: 3,
                  horizontal: 2,
                ),
                SizedBox(height: 14,),
                MyPageMenuItem(
                  icon: Icon(Icons.not_interested_outlined, color: Colors.black,),
                  title: '탈퇴하기',
                  press: joinoutDialog,
                  vertical: 3,
                  horizontal: 2,
                ),
              ],
            ),
          ),
      ),
    );
  }

  void logoutDialog(){
    showDialog(context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))
          ),
          title: Container(margin: EdgeInsets.only(bottom: 10),child: Center(child: Text('로그아웃'))),
          content: Text('로그아웃 하시겠습니까?'),
          actions: <Widget>[
            FlatButton(onPressed: ()=> Navigator.pop(context, false), child: Text('취소',style: TextStyle(color: Colors.lightGreen[800],fontWeight: FontWeight.bold),),
              // color: Colors.lightGreen,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            FlatButton(onPressed: () {
              _prefs.remove('token');
              _prefs.remove('state');
              loginServer.logout(token);
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => MyHomePage(index: 0,)), (route) => false);
            }, child: Text('로그아웃',style: TextStyle(color: Colors.lightGreen[800],fontWeight: FontWeight.bold)),
                // color: Colors.lightGreen,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),
          ],
        );
      }
    );
  }

  void joinoutDialog(){
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))
            ),
            title: Center(child: Text('회원 탈퇴 (이용계약 해지)')),
            content: Text(
                "신청하신 회원탈퇴는 약관에 따라 신속히 처리 해 드리겠습니다.\n"
                "다만, 거래사기 등의 부정이용 방지를 위해 거래를 진행중이거나 거래 관련 분쟁이 발생한 사용자는 이용계약 해지 및 회원탈퇴가 특정 기간 동안 제한될 수 있습니다.\n"
                "이용계약이 해지되면 법령 및 개인정보처리방침에 따라 사용자 정보를 보유하는 경우를 제외하고는 사용자 정보나 사용자가 작성한 게시물 등 모든 데이터는 삭제됩니다.\n"
                "탈퇴 후 일정 기간이내에 재가입은 1회에 한해 가능하며 재가입시 기존 평점은 복구됩니다.\n"
                "탈퇴를 진행 하시겠습니까?"
                ),
            actions: <Widget>[
              FlatButton(onPressed: ()=> Navigator.pop(context, false), child: Text('아니오',style: TextStyle(color: Colors.lightGreen[800]),)),
              FlatButton(onPressed: ()=> unJoin(), child: Text('예',style: TextStyle(color: Colors.lightGreen[800]),)),
            ],
          );
        }
    );
  }

  unJoin() async{
    Navigator.pop(context, false);
    try{
      String result = await loginServer.unjoin(token);
      print('result ==== $result');
      String message = jsonDecode(result)['message'];
      if(message == "Y"){
        completeBox(context, message);
        return Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => MyHomePage(index: 0,)), (route) => false);
      }else{
        completeBox(context, message);
      }
    } catch(e){
    Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }

  void completeBox(context, kind) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Container(
              color: Colors.transparent,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Container(
                    width: defaultSize * 40,
                    height: defaultSize * 20,
                    decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(15), ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: Text("회원탈퇴 ${kind == "Y" ? '완료' : '실패'} ", style: TextStyle(fontSize: defaultSize * 2))),
                        (kind == "N") ? Text( '진행중이 서비스가 있습니다.', style: TextStyle(fontSize: defaultSize * 2)) : Text(''),
                        Padding(padding: EdgeInsets.only(top: defaultSize *3)),
                        FlatButton(onPressed: ()=> Navigator.pop(context, true), color: Colors.purple,child: Text('확인', style: TextStyle(color: Colors.amber),))
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }


  Future<bool> _onBackPressed(){
    return Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => MyHomePage(index: 3,)), (route) => true);
  }
}