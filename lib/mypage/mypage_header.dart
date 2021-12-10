import 'dart:convert';

import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:any_rent/settings/url.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'mypage_server.dart';
import 'profile/mypage_profile.dart';


// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:4001"; //재승 내부 ip
const url = UrlConfig.url;

class MyPageHeader extends StatefulWidget {
  @override
  _MyPageHeaderState createState() => _MyPageHeaderState();
}

class _MyPageHeaderState extends State<MyPageHeader> {
  String token, nicNm, mbrId, mbrGrd;
  int prfSeq;
  bool isDisposed = false;
  Map<String, dynamic> profile;
  bool state;

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

  loadToken() async {
    token = await customSharedPreferences.getString('token');
    state = await customSharedPreferences.getBool('state');
    if (state) {
      try {
        String result = await myPageServer.getProfile(token);
        profile = jsonDecode(result);
      } catch (e) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
            "잠시후 다시 시도해 주세요.",
          ),
          duration: Duration(seconds: 3),
        ));
      }
      if (!isDisposed) {
        setState(() {
          prfSeq = profile['prfSeq'];
          nicNm = profile['nicNm'].toString();
          mbrId = profile['mbrId'].toString();
          mbrGrd = profile['mbrGrd'].toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Container(
      height: defaultSize * 35,
      child: Container(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: (prfSeq == null)
                                    ? AssetImage('assets/noimage.jpg')
                                    : NetworkImage(
                                        '$url/api/mypage/images?recieveToken=$prfSeq'),), //.
                            border: Border.all(
                                color: Colors.yellow.withOpacity(0.8),
                                width: 5)),
                        width: defaultSize * 15,
                        height: defaultSize * 20
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: defaultSize * 16,
                            // decoration: BoxDecoration(
                            //     border: Border.all(color:Colors.red),
                            // ),
                            child: Text(
                              (nicNm ?? ''),
                              style: TextStyle(
                                  fontSize: defaultSize * 2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          SizedBox(width: defaultSize * 2,),
                          Container(
                            margin: EdgeInsets.only(
                                right: defaultSize * 8.5),
                            child: Text(
                              (mbrId ?? ''),
                              style: TextStyle(
                                  fontSize: defaultSize * 2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellowAccent),
                            ),
                            // decoration: BoxDecoration(
                            //   border: Border.all(color:Colors.red),
                            // ),
                          ),
                        ],
                      ),
                      SizedBox(height: defaultSize * 1.5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: defaultSize * 3),
                            // decoration: BoxDecoration(
                            //   border: Border.all(color:Colors.red),),
                            child: Text(
                              ('평점'),
                              style: TextStyle(
                                  fontSize: defaultSize * 2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          SizedBox(width: defaultSize*2,),
                          Container(
                            width: defaultSize * 6,
                          //   decoration: BoxDecoration(
                          //     border: Border.all(color:Colors.red),
                          //
                          // ),
                            margin: EdgeInsets.only(right: defaultSize * 1),
                            child: Text(
                              (mbrGrd ?? ''),
                              style: TextStyle(
                                fontSize: defaultSize * 2,
                                fontWeight: FontWeight.bold,
                                color: Colors.yellowAccent
                            ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: defaultSize * 1,),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  width: defaultSize * 15,
                  height: defaultSize * 4,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: FlatButton(
                      child: Text(
                        '프로필 보기',
                        style: TextStyle(
                            fontSize: defaultSize * 1.8,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute
                            (
                              builder: (context) => MyPageProfile()))),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
