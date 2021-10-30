import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'main_home.dart';

void main() => runApp(MyApp());

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
        // if it's a RTL language
      ],
      supportedLocales: [
        const Locale('ko', 'KR'),
        // include country code too
      ],
    );
  }
}