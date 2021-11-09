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
  String token, mbrId, junId , hanId, jobId, twmNm, nicNm, chatCnt, junHan;
  bool state;
  bool isDisposed = false;
  int prfSeq;
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
            chatItems = widget.chatItems;
          });
          if(junHan == "H"){
            print('merId ============================= hanId');
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

      // print('chatDate ======================= $chatDate');
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
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return GestureDetector(
      onLongPress: () => print('길게 누르기'),
      onTap: (){
        print('ChatItem ==================');
        print('junId ============== $junId');
        print('mbrId ============== $mbrId');
        print('hanId ============== $hanId');
        // print('chatItems ================================== $chatItems');

        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(mbrId: mbrId, jobId: jobId, junId: junId, hanId: hanId,)));
      },
      child: Card(
        child: Container(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(margin: EdgeInsets.only(right: 10),
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
                  height: defaultSize * 15
                // child: (junPrfSeq == null) ? Icon(Icons.account_box_rounded, size: 40,) : Image.network('$url/api/mypage/images?recieveToken=$junPrfSeq')
              ),
              // Container(child: (prfSeq == null) ? Icon(Icons.account_box_rounded, size: defaultSize * 8,) :
              // Image.network('$url/api/mypage/images?recieveToken=$prfSeq') ),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(margin: EdgeInsets.only(left: 20), child: Text(nicNm ?? '', style: TextStyle(fontSize: defaultSize * 1.7,fontWeight: FontWeight.bold),)), //유저 닉네임으로 해야함
                          Text(twmNm ?? '', style: TextStyle(fontSize: defaultSize * 1.7,fontWeight: FontWeight.bold,color: Colors.lightGreen),), //job 동네 이름으로 해야함
                          Text('${screenDate ?? ''}', style: TextStyle(fontSize: defaultSize * 1.7,fontWeight: FontWeight.bold,color: Colors.amber[700]),) //마지막 시간이 오늘이 아니면 날짜 오늘이면 시간으로 표시
                        ],
                      ),
                    ),
                    Container(
                        height: 40,
                        width: 220,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0),color: Colors.lightGreen),
                        margin: EdgeInsets.only(left: 10,top: 12),
                        padding: EdgeInsets.only(top: 2,left: 20),
                        alignment: Alignment.centerLeft,
                        child:
                        // Text(chatCnt ?? '', style: TextStyle(fontSize: defaultSize * 1.8),)
                        textView (defaultSize, chatCnt ?? '메세지 내용이 없습니다.',)
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

  Widget textView (defaultSize, chatCnt){
    // print(messages[index]['message'].length);
    if(chatCnt.length > 18 ){
      return Text(chatCnt.substring(0,19)+"...", style: TextStyle( fontSize: defaultSize * 1.4), );
    }
    return Text(chatCnt, style: TextStyle(fontSize: defaultSize * 1.4,color: Colors.white), );
  }
}