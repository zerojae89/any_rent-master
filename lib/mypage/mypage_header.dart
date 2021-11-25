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
                        height: defaultSize * 18
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              (nicNm ?? ''),
                              style: TextStyle(
                                  fontSize: defaultSize * 2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 0),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 2.1),
                            child: Text(
                              (mbrId ?? ''),
                              style: TextStyle(
                                  fontSize: defaultSize * 2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellowAccent),
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.symmetric(
                                vertical: 2.5, horizontal: 8),
                            child: Text(
                              ('평점.'),
                              style: TextStyle(
                                  fontSize: defaultSize * 2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 12,left: 10,top: defaultSize * 0.5),
                            child: Text(
                              (mbrGrd ?? ''),
                              style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontSize: defaultSize * 2,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
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
