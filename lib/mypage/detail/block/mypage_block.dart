import 'package:flutter/material.dart';
import '../mypage_detail_appbar.dart';

class MyPageDetailBlock extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MyPageDetailAppbar( title: '차단',),
        ],
      ),
    );
  }
}