import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:any_rent/settings/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'login_server.dart';
import 'package:any_rent/main_home.dart';
import '../mypage/profile/mypage_profile.dart';

const LoginUrl = 'https://211.253.20.112/api/auth/facebook';

class FacebookLoginWebView extends StatefulWidget{
  @override
  _FacebookLoginWebViewState createState() => _FacebookLoginWebViewState();
}

class _FacebookLoginWebViewState extends State<FacebookLoginWebView> {

  final globalKey = GlobalKey<ScaffoldState>();
  FlutterWebviewPlugin webviewPlugin = FlutterWebviewPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  StreamSubscription _onDestroy;
  bool state;
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  @override
  void initState() {
    super.initState();

    _onStateChanged = webviewPlugin.onStateChanged.listen((state)  {
      final type = state.type;
      final url = state.url;
      print(url);
    });

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = webviewPlugin.onDestroy.listen((_) {
      if (mounted) globalKey.currentState.showSnackBar( const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    });
  }

  @override
  void dispose() {
    _onDestroy.cancel();
    super.dispose();
  }

  bool isAppLink(String url) {
    final appScheme = Uri.parse(url).scheme;
    return appScheme != 'http' &&
        appScheme != 'https' &&
        appScheme != 'about:blank' &&
        appScheme != 'data';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      body:  WebviewScaffold(
        url: LoginUrl,
        ignoreSSLErrors: true, // https 이나 인증서가 정상적이지 않는 경우 하얀 화면이 뜨는데 그것을 없애 주는 것
        invalidUrlRegex: Platform.isAndroid
            ? '^(?!https://|http://|about:blank|data:).+'
            : null,
        javascriptChannels: Set.from([
          JavascriptChannel(
              name: "Login",
              onMessageReceived: (JavascriptMessage result){
                Map<String, dynamic> user = jsonDecode(result.message);
                String mbrId = user['mbrId'];
                bool newUser = user['newUser'];
                _firebaseMessaging.getToken().then((macAdr) async {
                  sendDevice(mbrId, macAdr, newUser);
                });
              }
          ),
        ]),
        // hidden: ,
      ),
    );
  }

  static const platform = MethodChannel('anylinker.any_rent/login');

  Future<String> getAppUrl(String url) async {
    if (Platform.isAndroid) {
      return await platform.invokeMethod('pass_login', <String, Object>{'url': url});
    } else {
      return url;
    }
  }

  Future<String> getMarketUrl(String url) async {
      return await platform.invokeMethod('getMarketUrl', <String, Object>{'url': url});
  }

  Future<String> sendDevice(String mbrId, String macAdr, bool newUser) async {
    try{
      String responeToken = await loginServer.sendDeviceToken(mbrId, macAdr);
      // 회원 인증시 에러 날 경우 에러 처리
      if(responeToken == 'error'){
        webviewPlugin.close();
        Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
        Future.delayed(Duration(seconds: 3), (){
          return Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyHomePage(index: 0,)), (route) => false);
        });
      }
      // 사용자 토큰 및 디바이스 토큰 저장
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        prefs.setString("token", responeToken);
        prefs.setString('macAdr', macAdr);
        prefs.setBool('state', true);
      });
      //최초가입 재로그인 판단 여부
      if(newUser) return Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyPageProfile()), (route) => false);
      return Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyHomePage(index: 0,)), (route) => false);
    } catch(e){
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }
}