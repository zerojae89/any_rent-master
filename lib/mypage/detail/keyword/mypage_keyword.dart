import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import '../mypage_detail_appbar.dart';
import '../../../settings/size_config.dart';

class MyPageDetailKeyword extends StatefulWidget {

  @override
  _MyPageDetailKeywordState createState() => _MyPageDetailKeywordState();
}

class _MyPageDetailKeywordState extends State<MyPageDetailKeyword> {
  String token, mbrId, keyWord, uyn;
  bool state;
  bool isDisposed = false;
  int keySeq;
  DateFormat fsrgDtm = DateFormat("yyyy-mm-dd HH:mm:ss");
  DateFormat lschDtm = DateFormat("yyyy-mm-dd HH:mm:ss");


  TextEditingController _controller;
  var keyWordArrayList = [];

  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  loadToken() async{
    token = await customSharedPreferences.getString('token');
    state = await customSharedPreferences.getString('state');

    // try{
    //   if(state){
    //     if(!isDisposed) {
    //       mbrId = widget.keyWord['mbrid'];
    //
    //     }
    //   }
    // }
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
            margin: EdgeInsets.all(20.0),
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
                          Container(
                            width: 220,
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
                          Container( width: 80,
                            decoration: (BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0)
                            )),
                            child:  RaisedButton( color: Colors.lightGreen[400],shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                            ),
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