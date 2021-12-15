import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import '../mypage_server.dart';
import 'dart:convert';
import 'package:any_rent/main_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPageProfileNicName extends StatefulWidget{
  const MyPageProfileNicName({ Key key,  this.icon, this.title, this.horizontal, this.vertical, this.token }) : super(key: key);
  final Icon icon;
  final String title;
  final int horizontal;
  final int vertical;
  final String token;

  @override
  _MyPageProfileNicNameState createState() => _MyPageProfileNicNameState();
}

class _MyPageProfileNicNameState extends State<MyPageProfileNicName> {
  String result, nicNm, token;
  SharedPreferences _prefs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadNicNm();
  }

   _loadNicNm() async{
    _prefs = await SharedPreferences.getInstance();
    token = _prefs.getString('token');
    result = await myPageServer.getProfile(token);
    Map<String, dynamic> profile = jsonDecode(result);
    setState(() { nicNm = profile['nicNm']; });
    print('nicNm ==== $nicNm');
  }



  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return WillPopScope(
        onWillPop: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(index: 3,))),
      child: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 40,left: 20),
              child: Row(
                children: [
                  widget.icon,
                  SizedBox(width: defaultSize * 2,),
                  Text( '닉네임 : ',  style: TextStyle( fontSize: 19,fontWeight: FontWeight.bold ),),
                  SizedBox(width: defaultSize * 1,),
                  Container(width:130,child: Text( (nicNm ?? '' ),  style: TextStyle( fontSize: 19,fontWeight: FontWeight.bold,color: Colors.lightGreen[700]), )),
                  // Spacer(),
                  Container(
                      height: 40,
                      width: 80,
                      decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.lightGreen,
                  ),
                      child:
                  FlatButton(onPressed: () => nicNameDialog(),  child:  Text( '변경',  style: TextStyle( color: Colors.white,fontSize: defaultSize * 1.5, ), ),)),
                ],
              ),
            ),
          ),
          // Divider()
        ],
      ),
    );
  }

  void nicNameDialog(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            title: Center(child: Text('닉네임'),),
            content: Builder(
                builder: (BuildContext context){
                  return Form(
                    key: formKey,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: '닉네임', hintText: '변경할 닉네임'),
                      autofocus: true,
                      validator: (value){ if(value.isEmpty){ return '닉네임을 입력해주세요'; } else{ return null; } }, //null check
                      onSaved: (value){ nicNm = value; },
                    ),
                  );
                },
              ),
            actions: <Widget>[
              FlatButton(onPressed: () => Navigator.pop(context, false), child: Text('취소', style: TextStyle(color: Colors.lightGreen[800]),)),
              FlatButton(onPressed: validateAndSave , child: Text('변경', style: TextStyle(color: Colors.lightGreen[800]),)),
            ],
          );
        }
    );
  }

  //닉네임 변경
  void validateAndSave() async{
    final form = formKey.currentState;
    if(form.validate()) {
      form.save();
      String result = await myPageServer.changrNic(token, nicNm);
      if(result != 'error') {
        setState(() { nicNm; });
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('닉네임이 변경되었습니다.')));
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('잠시후 다시 시도해 주세요')));
      }
      Navigator.pop(context, true);
    }
  }
}