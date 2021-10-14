import 'package:flutter/material.dart';
import '../mypage_detail_appbar.dart';
import '../../../settings/size_config.dart';

class MyPageDetailKeyword extends StatefulWidget {
  @override
  _MyPageDetailKeywordState createState() => _MyPageDetailKeywordState();
}

class _MyPageDetailKeywordState extends State<MyPageDetailKeyword> {


  TextEditingController _controller;
  var keyWordArrayList = [];
  String keyWord;

  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Scaffold(
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MyPageDetailAppbar(title: '키워드',),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.only(top: defaultSize)),
                Padding(padding: EdgeInsets.all(defaultSize),
                  child:  Text( '키워드 알림',  style: TextStyle( fontSize: defaultSize * 3,  fontWeight: FontWeight.bold ), ), ),
                Padding(padding: EdgeInsets.all(defaultSize ), child:  Text('키워드를 입력하여 알림을 받으세요',  style: TextStyle( fontSize: defaultSize * 1.6 ), ), ),
                Container(
                  child: SizedBox(
                    width: double.infinity,
                    height: defaultSize * 17,
                    child: Padding(
                      padding: EdgeInsets.only(left: defaultSize, right: defaultSize),
                      child: Row(
                        children: [
                          Expanded( flex: 6,
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              decoration: InputDecoration(
                                // border: InputBorder.none, // 하단 밑줄 제거s
                                hintText: '키워드를 입력해 주세요',
                                labelText: '키워드',
                              ),
                            ),
                          ),
                          Expanded( flex: 2,
                            child:  RaisedButton( color: Colors.lightGreen[400],
                              child: Text( '등록', style: TextStyle( color: Colors.white ), ),
                              onPressed: (){
                                keyWord = _controller.text;
                                print('keyWord =  $keyWord');
                                _controller.clear();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}