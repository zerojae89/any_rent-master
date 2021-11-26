import 'package:flutter/material.dart';
import '../../../main_home.dart';
import 'read/mypage_review_read.dart';
import 'wirte/mypage_review_write.dart';

class MyPageReview extends StatefulWidget {
  MyPageReview({Key key, this.index}) : super(key: key);
  final int index;
  @override
  _MyPageReviewState createState() => _MyPageReviewState();
}

class _MyPageReviewState extends State<MyPageReview> {
  String token, mbrId, jobId, jobTtl, junHan, myId, opId, myNicNm, opNicNm, revCtn;
  int jobAmt, bidAmt,    totMbrGrd, mbrGrd, currentIndex;
  bool isDisposed = false;
  List<dynamic> reviewItems = [];

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

  List<Widget> children = [MyPageReviewWrite(), MyPageReviewRead()];
  void onTap(int index) { if(!isDisposed) setState(() => currentIndex = index ); } // 하단 네비게이션 바 인덱스 변경

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        body: children[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            onTap: onTap, //하단 네이게이션 페이지 이동
            currentIndex: currentIndex, // 현제 페이지
            selectedItemColor: Colors.amber, // 선택된 색상
            unselectedItemColor: Colors.black, // 선택 안된 색상
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.brush_outlined),
                label: '후기작성'),
              BottomNavigationBarItem(
                icon: Icon(Icons.chrome_reader_mode_outlined),
                label: '후기확인'),
            ]
        ),
      ),
    );
  }

  Future<bool> onBackPressed() => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyHomePage(index: 3,)), (route) => false);
}