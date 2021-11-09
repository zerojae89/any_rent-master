import 'dart:convert';

import 'package:any_rent/chat/chat_page.dart';
import 'package:any_rent/home/home_server.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/home/home_detail_dialog.dart';

import '../../../mypage_server.dart';
import '../mypage_list.dart';

class AttentionBottom {

  userState(jobSts, size, defaultSize, context, jobTtl, jobCtn, jobStDtm, token, jobId, junId){
    switch(jobSts){
      case "1" :{
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width / 2,
              height: defaultSize * 6,
              child: FlatButton(
                color: Colors.lightGreen,
                onPressed: () {
                  if(jobSts != "1") return Scaffold.of(context).showSnackBar( SnackBar(content: Text("예약 할 수 없습니다.",), duration: Duration(seconds: 3),) );
                  homeDetailDialog.showDialogFunc(context, defaultSize, jobTtl, jobCtn, jobStDtm, token, jobId);
                },
                child: Text( "예약하기",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 1.7,), ),
              ),
            ),
            Expanded(
              child: FlatButton(
                onPressed: () => userSendMessage(context, token, jobId, junId),
                child: Text("메세지"),
              ),
            ),
          ],
        );
      }
      break;
      case "2":{
        return Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width / 2,
                height: defaultSize * 6,
                child: FlatButton(
                  color: Colors.lightGreen,
                  onPressed: () => onComplComplete(context, jobId, token),
                  child: Text( "소일 완료하기",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 1.7,), ),
                ),
              ),
              Expanded(
                child: FlatButton(
                  onPressed: () => userSendMessage(context, token, jobId, junId),
                  child: Text("메세지 보내기"),
                ),
              ),
            ],
          ),
        );
      }
      break;
      case "5":{
        return Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width / 2,
                height: defaultSize * 6,
                child: FlatButton(
                  color: Colors.lightGreen,
                  onPressed: () => null,
                  child: Text( "주니 완료 대기중",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 1.7,), ),
                ),
              ),
              Expanded(
                child: FlatButton(
                  onPressed: () => userSendMessage(context, token, jobId, junId),
                  child: Text("메세지 보내기"),
                ),
              ),
            ],
          ),
        );
      }
      break;
      case "8":{
        return Container(
          color: Colors.lightGreen,
          child: SizedBox(
            width: double.infinity,
            height: defaultSize * 6,
            child: Center(child: Text( "시간초과",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 1.7,), )),
          ),
        );
      }
      break;
      case "9":{
        return Container(
          color: Colors.lightGreen,
          child: SizedBox(
            width: double.infinity,
            height: defaultSize * 6,
            child: Center(child: Text( "취소",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 1.7,), )),
          ),
        );
      }
      break;
      default :{
        return Container(
          color: Colors.lightGreen,
          child: SizedBox(
            width: double.infinity,
            height: defaultSize * 6,
            child: Center(child: Text( "완료",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 1.7,), )),
          ),
        );
      }
      break;
    }
  }




  sameState(jobSts, size, defaultSize, context, jobTtl, jobCtn, jobStDtm, token, jobId, junId){
    switch(jobSts) {
      case "1" : { return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width / 2,
                height: defaultSize * 6,
                child: FlatButton(
                  color: Colors.lightGreen,
                  onPressed: () => homeDetailDialog.onUpdatePressed(context, jobId),
                  child: Text("수정하기", style: TextStyle(
                    color: Colors.white, fontSize: defaultSize * 1.7,),),
                ),
              ),
              Expanded(
                child: FlatButton(
                  onPressed: () =>  onDeletePressed( context, jobId, token),
                  child: Text("삭제하기"),
                ),
              ),
            ],
          );
        }
        break;
      case "2":{
        return Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width / 2,
                height: defaultSize * 6,
                child: FlatButton(
                  color: Colors.lightGreen,
                  onPressed: () => onComplComplete(context, jobId, token),
                  child: Text( "소일 완료하기",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 1.7,), ),
                ),
              ),
              Expanded(
                child: FlatButton(
                  onPressed: () => sendMessage(context, token, jobId),
                  child: Text("메세지 보내기"),
                ),
              ),
            ],
          ),
        );
      }
      break;
      case "3":{
        return SizedBox(
          width: double.infinity,
          height: defaultSize * 6,
          child: FlatButton(
            color: Colors.lightGreen,
            onPressed: () {
              print( '완료');
            },
            child: Text( "완료",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 1.7,), ),
          ),
        );
      }
      break;
      case "4":{
        return SizedBox(
          width: double.infinity,
          height: defaultSize * 6,
          child: FlatButton(
            color: Colors.lightGreen,
            onPressed: () {
              print( '하니 선정중 ');
            },
            child: Text( "하니 선정중",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 1.7,), ),
          ),
        );
      }
      break;
      case "5":{
        return Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width / 2,
                height: defaultSize * 6,
                child: FlatButton(
                  color: Colors.lightGreen,
                  onPressed: () => onComplComplete(context, jobId, token),
                  child: Text( "소일 완료하기",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 1.7,), ),
                ),
              ),
              Expanded(
                child: FlatButton(
                  onPressed: () => sendMessage(context, token, jobId),
                  child: Text("메세지 보내기"),
                ),
              ),
            ],
          ),
        );
      }
      break;
      case "8":{
        return SizedBox(
          width: double.infinity,
          height: defaultSize * 6,
          child: FlatButton(
            color: Colors.lightGreen,
            onPressed: () => null,
            child: Text( "시간초과",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 1.7,), ),
          ),
        );
      }
      break;
      case "9":{
        return SizedBox(
          width: double.infinity,
          height: defaultSize * 6,
          child: FlatButton(
            color: Colors.lightGreen,
            onPressed: () => null,
            child: Text( "취소",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 1.7,), ),
          ),
        );
      }
      break;
      default:{
        return Container(
          color: Colors.lightGreen,
          child: SizedBox(
            width: double.infinity,
            height: defaultSize * 6,
            child: Center(child: Text( "상태없음",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 1.7,), )),
          ),
        );
      }
    }
  }

  onDeletePressed(context, jobId, token){ //삭제하기
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text("게시물을 삭제 하시겠습니까?"),
          actions: <Widget>[
            FlatButton(
              child: Text("아니오"),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
                child: Text("예"),
                onPressed: () {
                  try{
                    homeServer.deleteService(token, jobId);
                  } catch(e){
                  Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
                  }
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyPageDetailList(index: 2,)), (route) => false);
                }
            )
          ],
        )
    );
  }

  sendMessage(context, token, jobId) async{
    String mbrId, hanId;
    try{
      String idResult = await myPageServer.getProfile(token);
      Map<String, dynamic> profile = jsonDecode(idResult);
      debugPrint('Chat1 responeJson == $profile');
      mbrId  = profile['mbrId'];
      String hanIdResult = await myPageServer.getHanId(token);
      Map<String, dynamic> bidHanid = jsonDecode(hanIdResult);
      hanId = bidHanid['bidHanid'];
    } catch(e){
    Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
    print('sendMessage mbrId =============================== $mbrId');
    print('sendMessage hanId =============================== $hanId');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(mbrId: mbrId, jobId: jobId, junId: junId, hanId: mbrId,)));
  }

  userSendMessage(context, token, jobId, junId) async{
    String mbrId;
    try{
      String idResult = await myPageServer.getProfile(token);
      Map<String, dynamic> profile = jsonDecode(idResult);
      debugPrint('Chat1 responeJson == $profile');
      mbrId = profile['mbrId'];
    } catch(e){
    Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
    print('sendMessage mbrId =============================== $mbrId');
    print('sendMessage junId =============================== $junId');
    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(mbrId: mbrId, jobId: jobId, junId: junId, hanId: mbrId,)));
  }

  onComplComplete(context, jobId, token){ //소일 완료 하기
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text("소일을 완료 하시겠습니까?"),
          actions: <Widget>[
            FlatButton(
              child: Text("아니오"),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text("예"),
              onPressed: (){
                try{
                  myPageServer.sendServiceComplete(token, jobId);
                } catch(e){
                  Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
                }
                return Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyPageDetailList(index: 1,)), (route) => false);
              },
            )
          ],
        )
    );
  }

}

AttentionBottom attentionBottom = AttentionBottom();