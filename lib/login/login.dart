import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'login_webview.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Text('로그인이 필요한 서비스 입니다.', style: TextStyle(fontSize: 15),),
              Padding(padding: EdgeInsets.only(top: defaultSize * 2,bottom: 3)),
              Container(
                width: defaultSize * 35,
                height: defaultSize * 5,
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(15)
                ),
                child:
                FlatButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginWebView())),
                  child: Text( 'PASS 로그인 ',  style: TextStyle( fontSize: defaultSize * 2,color: Colors.white), ),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                width: defaultSize * 35,
                height: defaultSize * 5,
                decoration: BoxDecoration(
                    color: Colors.yellow[600],
                    borderRadius: BorderRadius.circular(15)
                ),
                child:
                FlatButton.icon(
                  onPressed: () {},

                  label: Text( 'KAKAO Talk 로그인',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                  icon: Icon(Icons.chat),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                width: defaultSize * 35,
                height: defaultSize * 5,
                decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(15)
                ),
                child:
                FlatButton(
                  onPressed: () {},
                  child: Text( 'Facebook 로그인',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: defaultSize * 35,
                height: defaultSize * 5,
                decoration: BoxDecoration(
                    color: Colors.lightGreenAccent[700],
                    borderRadius: BorderRadius.circular(15)
                ),
                child:
                FlatButton(
                  onPressed: (){},
                  child: Text( 'NAVER 로그인',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),)
                ),
              )
            ],
          ),

        ),
      ),

    );
  }
}