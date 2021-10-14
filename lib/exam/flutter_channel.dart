import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Belajar Method Channel"),
        ),
        body: Center(
          child: RaisedButton(
            child: Text("Tampilkan Toast"),
            onPressed: () {
              _showToast("Hai ini toast, blablablabla");
            },
          ),
        ),
      ),
    );
  }

  void _showToast(String message) async {
    bool resp = await MethodChannel("anylinker.any_rent/login").invokeMethod("show_toast", {"message": message});
    print('===============================');
    print(resp ? "Berhasil" : "Ga berhasil");
  }
}