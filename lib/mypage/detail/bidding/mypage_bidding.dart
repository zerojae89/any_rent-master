import 'package:any_rent/mypage/detail/bidding/waiter/mypage_bidding_waiter_list.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:flutter/material.dart';

import '../../../main_home.dart';
import 'bidder/mypage_bidding_bidder_list.dart';


class MyPageBiddingList extends StatefulWidget {
  MyPageBiddingList({Key key, this.index}) : super(key: key);
  final int index;
  @override
  _MyPageBiddingListState createState() => _MyPageBiddingListState();
}

class _MyPageBiddingListState extends State<MyPageBiddingList> {

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

  List<Widget> children = [MyPageBidderList(), MyPageWaiterList() ];

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
                title: Text('입찰선택'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_comment_outlined),
                title: Text('입찰확인'),
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
