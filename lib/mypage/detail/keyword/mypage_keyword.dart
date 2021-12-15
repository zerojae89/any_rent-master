import 'package:any_rent/mypage/mypage_server.dart';
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
  bool isDisposed = false;
  int keySeq;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();



  void initState() {
    loadToken();
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  loadToken() async{
    token = await customSharedPreferences.getString('token');
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
                            child: Form(
                              key: formKey,
                              child: TextFormField(
                                decoration: InputDecoration(hintText: '키워드를 입력해 주세요'),
                                autofocus: true,
                                validator: (value){ if(value.isEmpty){ return '키워드를 입력해주세요'; } else{ return null; } }, //null check
                                onSaved: (value){ keyWord = value; },
                              ),
                            ),
                          ),
                          // Container(
                          //   width: 220,
                          //   child: TextField(
                          //     controller: _controller,
                          //     autofocus: true,
                          //     decoration: InputDecoration(
                          //       // border: InputBorder.none, // 하단 밑줄 제거s
                          //       hintText: '키워드를 입력해 주세요',
                          //       labelText: '키워드',
                          //     ),
                          //   ),
                          // ),
                          Container( width: 80,
                            decoration: (BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0)
                            )),
                            child:  RaisedButton( color: Colors.lightGreen[400],shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                            ),
                              child: Text( '등록', style: TextStyle( color: Colors.white ), ),
                              onPressed:validateAndSave
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
  void validateAndSave() async{
    final form = formKey.currentState;
    if(form.validate()) {
      form.save();
      print('===========2222222$keyWord');
      String result = await myPageServer.keyWordRegi(token, keyWord);
      print('=======33333333===$result');
      // String result = await myPageServer.changrNic(token, nicNm);
      // if(result != 'error') {
      //   setState(() { nicNm; });
      //   Scaffold.of(context).showSnackBar(SnackBar(content: Text('닉네임이 변경되었습니다.')));
      // } else {
      //   Scaffold.of(context).showSnackBar(SnackBar(content: Text('잠시후 다시 시도해 주세요')));
      // }
      // Navigator.pop(context, true);
    }
  }
}

