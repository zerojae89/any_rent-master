import 'package:any_rent/settings/size_config.dart';
import 'package:flutter/material.dart';
import '../../../main_home.dart';
import 'attention/mypage_list_attention_list.dart';
import 'han/mypage_list_han_work_list.dart';
import 'jun/mypage_list_jun_work_list.dart';

class MyPageDetailList extends StatefulWidget {
  MyPageDetailList({Key key, this.index}) : super(key: key);
  final int index;
  @override
  _MyPageDetailListState createState() => _MyPageDetailListState();
}

class _MyPageDetailListState extends State<MyPageDetailList> {

  bool isDisposed = false;
  final globalKey = GlobalKey<ScaffoldState>();
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.index;
    super.initState();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  List<Widget> children = [MyPageJunWorkList(), MyPageHanWorkList(), MyPageAttentionWorkList()];

  void onTap(int index) { if(!isDisposed) setState(() => currentIndex = index ); } // 하단 네비게이션 바 인덱스 변경

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        key: globalKey,
        body: children[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            onTap: onTap, //하단 네이게이션 페이지 이동
            currentIndex: currentIndex, // 현제 페이지
            selectedItemColor: Colors.amber, // 선택된 색상
            unselectedItemColor: Colors.black, // 선택 안된 색상
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                title: Text('준일'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_comment_outlined),
                title: Text('한일'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message_outlined),
                title: Text('관심'),
              ),
            ]
        ),
      ),
    );
  }

  Future<bool> onBackPressed() {//뒤로가기 마이페이지로 이동
    return Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyHomePage(index: 3,)), (route) => false);
  }
}


