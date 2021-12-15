import 'dart:convert';

import 'package:any_rent/settings/size_config.dart';
import 'package:any_rent/settings/url.dart';
import 'package:intl/intl.dart';
import 'package:any_rent/mypage/mypage_server.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart';

// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:4001"; //재승 내부 ip
const url = UrlConfig.url;

class ChatItem extends StatefulWidget{
  final Map <String, dynamic> chatItems;
  const ChatItem({ Key key, this.chatItems}) : super(key: key);
  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  String token, jobId, twmNm, nicNm, chatCnt, junHan, mbrId, junId, hanId;
  bool state;
  bool isDisposed = false;
  int prfSeq, unreadMsg;
  Map <String, dynamic> chatItems;
  DateFormat yearDateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  DateFormat dateFormat = DateFormat("MM월 dd일");
  DateFormat timeFormat = DateFormat("HH시 mm분");
  var screenDate;


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


  loadToken() async{
    // print('widget.chatItems =========================================== ${widget.chatItems}');
    token = await customSharedPreferences.getString('token');
    // debugPrint('Chat token == $token');
    state =  await customSharedPreferences.getBool('state');
    // debugPrint('Chat state == $state');
    try{
      if(state){
        if(!isDisposed) {
          setState(() {
            // mbrId = widget.mbrId;
            junId = widget.chatItems['junId'];
            hanId = widget.chatItems['hanId'];
            jobId = widget.chatItems['jobId'];
            twmNm = widget.chatItems['twmNm'];
            nicNm = widget.chatItems['nicNm'];
            prfSeq = widget.chatItems['prfSeq'];
            chatCnt = widget.chatItems['chatCnt'];
            mbrId = widget.chatItems['myId'];
            junHan = widget.chatItems['junHan'];
            unreadMsg = widget.chatItems['unreadMsg'];
            chatItems = widget.chatItems;
          });
          if(junHan == "H"){
            print('merId ============================= hanId');
            print('unread ================22============= $unreadMsg');
            if(!isDisposed) {
              setState(() {
                hanId = widget.chatItems['myId'];
                junId = widget.chatItems['opId'];
              });
            }
          } else {
            if(!isDisposed) {
              setState(() {
                hanId = widget.chatItems['opId'];
                junId = widget.chatItems['myId'];
              });
            }
          }
        }
        if(chatCnt == ' '){
          print('chatCnt ============================= ''');
          if(!isDisposed) {
            setState(() {
              chatCnt = '메세지가 없습니다.';
            });
          }
        }
      }

      var chatDate = dateFormat.format(DateTime.parse(chatItems['lschDtm']));

      print('chatDate ======================= $chatDate');
      var now = dateFormat.format(DateTime.now());
      // print('now =========================== $now');
      int compare = now.compareTo(chatDate); //날짜 비교 작업 시작날짜와 입찰 날짜 비교
      if (compare == 0 ){
        if(!isDisposed) { setState(() => screenDate = timeFormat.format(DateTime.parse(chatItems['lschDtm']))); }
      } else {
        if(!isDisposed) { setState(() => screenDate = dateFormat.format(DateTime.parse(chatItems['lschDtm']))); }
      }
      // print('compare =============== $compare');
    } catch(e){
      print('==================$e');
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }

  String UnreadMsg(){
    if(unreadMsg>0){
      print('===============55555$unreadMsg');
      setState(() {
        '$unreadMsg';
      });
    }
    return "";
  }

  // String ChatCnt(){
  //   setState((){
  //     chatCnt;
  //   });
  //   return "";
  // }


  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return GestureDetector(
      onLongPress: () => print('길게 누르기'),
      onTap: (){
        print('ChatItem ==================');
        print('junId ============== $junId');
        print('mbrId ============== $mbrId');
        print('hanId ========55=== $unreadMsg');
        // print('chatItems ================================== $chatItems');

        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(mbrId: mbrId, jobId: jobId, junId: junId, hanId: hanId,)));
      },
      child: Card(
        child: Container(
          height: defaultSize * 14,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(margin: EdgeInsets.only(left: defaultSize * 0.4),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: (prfSeq == null)
                              ? AssetImage('assets/noimage.jpg')
                              : NetworkImage(
                              '$url/api/mypage/images?recieveToken=$prfSeq')), //.
                      // border: Border.all(
                      //     color: Colors.yellow.withOpacity(0.8),
                      //     width: 5)
                  ),
                  width: defaultSize * 9,
                  height: defaultSize * 12
                // child: (junPrfSeq == null) ? Icon(Icons.account_box_rounded, size: 40,) : Image.network('$url/api/mypage/images?recieveToken=$junPrfSeq')
              ),
              // Container(child: (prfSeq == null) ? Icon(Icons.account_box_rounded, size: defaultSize * 8,) :
              // Image.network('$url/api/mypage/images?recieveToken=$prfSeq') ),
              Container(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(width: defaultSize*1.5,),
                          Container(
                            child: Text(nicNm ?? '', style: TextStyle(fontSize: defaultSize * 1.5,fontWeight: FontWeight.bold),textAlign: TextAlign.left,),
                            width: defaultSize * 12,
                          //     decoration: BoxDecoration(
                          // color: Colors.blue.withOpacity(0.3)),
                          ),
                          Container(
                            width: defaultSize * 6,
                              // decoration: BoxDecoration(
                              //     border:Border.all(color: Colors.red)
                              // ),
                              child: Text(twmNm ?? '', style: TextStyle(fontSize: defaultSize * 1.5,fontWeight: FontWeight.bold,color: Colors.lightGreen[700]),)
                              ), //job 동네 이름으로 해야함
                          (unreadMsg == 0)? Container(width: defaultSize * 4, ) : Container(
                            padding: EdgeInsets.all(defaultSize * 0.4),
                            width: defaultSize * 4,
                            height: defaultSize * 2.7,
                            decoration: BoxDecoration(
                               shape: BoxShape.circle,color: Colors.pink),
                            child: Text('$unreadMsg',style: TextStyle(color: Colors.white,fontSize: defaultSize * 1.7),textAlign: TextAlign.center,),
                              // unreadMsg==0 ? '':'$unreadMsg
                          ),

                           //마지막 시간이 오늘이 아니면 날짜 오늘이면 시간으로 표시
                        ],
                      ),
                    ),
                        Container(
                            margin: EdgeInsets.only(left: 10,top: 12),
                            padding: EdgeInsets.only(top: defaultSize * 1,left: 20,bottom: defaultSize * 1.4),
                            height: defaultSize * 5,
                            width: defaultSize * 24,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.lightGreen
                            ),
                            alignment: Alignment.centerLeft,
                            child:
                            // Text(chatCnt ?? '', style: TextStyle(fontSize: defaultSize * 1.8),)
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(top: defaultSize * 0.5),
                                  width: defaultSize * 13,
                                    height: defaultSize * 2.5,
                                //     decoration: BoxDecoration(
                                //   border:Border.all(color: Colors.white)
                                // ),

                                    child: textView (defaultSize, chatCnt ?? '메세지 내용이 없습니다.',)

                                ),
                                Container(
                                    margin: EdgeInsets.only(left:defaultSize * 0.2 ),
                                    width: defaultSize * 6,
                                    // decoration: BoxDecoration(
                                    //     border:Border.all(color: Colors.red)
                                    // ),
                                    child: Text('${screenDate ?? ''}', style: TextStyle(fontSize: defaultSize * 1.3,color: Colors.yellowAccent),textAlign: TextAlign.right,))
                              ],
                            )
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Widget countview(){
  //   if (unread_msg>=0){
  //     return Text($unread_msg.toString());
  //   }
  // }



  Widget textView (defaultSize, chatCnt){
    // print(messages[index]['message'].length);
    if(chatCnt.length > 8 ){
      return Text(chatCnt.substring(0,9)+"...", style: TextStyle( fontSize: defaultSize * 1.7,color: Colors.white), );
    }
    return Text(chatCnt, style: TextStyle(fontSize: defaultSize * 1.7,color: Colors.white), );
  }
}