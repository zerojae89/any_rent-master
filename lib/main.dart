import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'main_home.dart';
import 'package:kakao_flutter_sdk/all.dart';

void main() {
    KakaoContext.clientId="3f2e549baa12899e3d42afa90cf782b7";
    KakaoContext.javascriptClientId="53906cd63e84ac614ce233df62b103a1";
    runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AnyRent',
      theme: ThemeData( primaryColor: Colors.white), // 앱에 매인 테마 색을 정한다.
      home: MyHomePage(index: 0),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate
        // if it's a RTL language
      ],
      supportedLocales: [
        const Locale('ko', 'KR'),
        // include country code too
      ],
    );
  }
}