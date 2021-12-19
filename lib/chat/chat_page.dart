import 'dart:convert';
import 'package:any_rent/chat/chat_server.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:any_rent/settings/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:intl/intl.dart';
import '../main_home.dart';

// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:3000"; //재승 내부 ip
// const chatUrl = 'http://211.253.20.112:3443'; //개발서버
// const chatUrl = "http://192.168.1.3:3000"; //재승 내부 ip
const url = UrlConfig.url; // 서버 주소
const chatUrl = UrlConfig.url+':3443'; //개발서버 (채팅전용?)

class ChatPage extends StatefulWidget {
  final String jobId, hanId, junId, mbrId;
  ChatPage({ Key key, @required this.jobId, this.hanId, this.junId, this.mbrId}) : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  SocketIO socketIO;
  List messages;  //? 이해 안감
  double height, width;
  TextEditingController textController; //키보드 타이핑 텍스트를 데이터화 하는 기능
  ScrollController scrollController; // 화면을 스크룰 방식으로 볼 수 있게 하는 기능
  final globalKey = GlobalKey<ScaffoldState>(); //반복적으로 쓰이는 안내메세지를 계속 쓰는 기능.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isDisposed = false;
  String jobId, token, junId, mbrId, roomCode, hanId, myNic, userNic;
  int myPrfSeq, userPrfSeq;
  String queryString ="";
  var screenDate;
  DateFormat timeFormat = DateFormat("HH시 mm분");
  DateFormat dateFormat = DateFormat("MM월 dd일");
  DateFormat dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  @override
  void initState() {
    messages = List(); // ? 이해 안감
    textController = TextEditingController();
    scrollController = ScrollController();
    if(!isDisposed) {
      setState(() {
        jobId = widget.jobId;
        junId = widget.junId;
        mbrId = widget.mbrId;
        hanId = widget.hanId;
        roomCode = jobId+junId+hanId;
      });
    }
    queryString = 'jobId=${widget.jobId}&junId=${widget.junId}&hanId=${widget.hanId}&mbrId=${widget.mbrId}';
    socketIO = SocketIOManager().createSocketIO( chatUrl,   '/',  query: queryString,  socketStatusCallback: socketStatus );
    socketIO.init();
    socketIO.connect();
    getChatCnt();
    super.initState();

  }

  getChatCnt()async{ //채팅 내용 불러오기
    try{
      String result = await chatServer.getChatCnt(widget.jobId, widget.junId, widget.hanId);
      if(!isDisposed){setState(() => messages = jsonDecode(result)['message'] );}
      print('getChatCnt messages ========================= ${messages.length}');
      print('getChatCnt messages ========================= $messages');
      if(messages.length >= 1)  { //채팅 방으로 들어온 경우
        print('===========================================================333333333');
        messages.removeAt(0);
        Map<String, dynamic> profile = jsonDecode(result)['profile'];
        if(mbrId == profile['JUNID']){ //내가 주니인 경우
          if(!isDisposed){
            setState(() {
              myNic = profile['J_NIC_NM'];
              myPrfSeq = profile['J_PRF_SEQ'];
              userNic = profile['H_NIC_NM'];
              userPrfSeq = profile['H_PRF_SEQ'];
            });
          }
        } else { //내가 하니인 경우
          if(!isDisposed){
            setState(() {
              myNic = profile['H_NIC_NM'];
              myPrfSeq = profile['H_PRF_SEQ'];
              userNic = profile['J_NIC_NM'];
              userPrfSeq = profile['J_PRF_SEQ'];
            });
          }
        }
      }else { // 상세보기에서 메세지 보낸 경우
        print('=====================================================================');
        String result;
        if(widget.mbrId == widget.junId){ // 멤버아이디와 하니 아이디를 던져 닉네임과 프로필을 얻어온다
          print('=============================================================1111111111');
          result = await chatServer.getProfile(widget.mbrId, widget.hanId);
          List<dynamic> profile = jsonDecode(result)['profile'];
          if(!isDisposed){
            setState(() {
              myNic = profile[0]['myNicNm'];
              myPrfSeq = profile[0]['myPrfSeq'];
              userNic = profile[0]['userNicNm'];
              userPrfSeq = profile[0]['userPrfSeq'];
            });
          }
        } else { // 멤버아이디와 주니 아이디를 던져 닉네임과 프로필을 얻어온다
          print('===========================================================2222222222');
          result = await chatServer.getProfile(widget.mbrId, widget.junId);
          List<dynamic> profile = jsonDecode(result)['profile'];
          if(!isDisposed){
            setState(() {
              myNic = profile[0]['myNicNm'];
              myPrfSeq = profile[0]['myPrfSeq'];
              userNic = profile[0]['userNicNm'];
              userPrfSeq = profile[0]['userPrfSeq'];
            });
          }
        }
      }

    } catch(e){
      print(e);
      globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    }
  }

  @override
  void dispose() {
    print('***********************************************************************');
    SocketIOManager().destroySocket(socketIO);
    socketIO.disconnect();
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    print('myNic ============================= $myNic');
    print('myPrfSeq ============================= $myPrfSeq');
    print('userNic ============================= $userNic');
    print('userPrfSeq ============================= $userPrfSeq');
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        key: globalKey,
        appBar:  AppBar(
          centerTitle: true,
          title: Text(userNic ?? ''),
          leading: IconButton( icon: Icon(Icons.arrow_back),  onPressed: ()=> Navigator.pop(context) ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: height * 0.8,
                width: width,
                child: ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    return (messages[index]['message'] != null) ?  Container(
                      alignment: messages[messages.length - index -1]['name'] == mbrId
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Column(
                        children: [
                          Container(alignment: messages[messages.length - index -1]['name'] == mbrId  ? Alignment.centerRight  : Alignment.centerLeft, padding: EdgeInsets.all(defaultSize) ,
                              child: Text(
                                  messages[messages.length - index -1]['name'] == mbrId  ? myNic?? '' : userNic ?? '',style: TextStyle(color: Colors.lightGreen[700],fontWeight: FontWeight.bold),
                              )),
                          Container(
                            padding: EdgeInsets.all( defaultSize ),
                            margin:  EdgeInsets.only(bottom: defaultSize ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child:
                            messages[messages.length - index -1]['name'] == mbrId
                                ?
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                dataView(defaultSize, messages.length - index -1),
                                // Text('${index.toString()}'),
                                Container(
                                  padding:  EdgeInsets.all(defaultSize * 1 ),
                                  margin:  EdgeInsets.only(left: defaultSize ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[700],
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child:textView (defaultSize, messages.length - index -1),
                                ),
                                // Container(
                                //   margin:  EdgeInsets.only(bottom: defaultSize, left: defaultSize),
                                //   decoration: BoxDecoration(
                                //     color: Colors.white,
                                //     borderRadius: BorderRadius.circular(defaultSize * 5),
                                //   ),
                                //   child: (myPrfSeq == null) ? Icon(Icons.account_box_rounded, size: defaultSize * 7,) :
                                //   Image.network('$url/api/mypage/images?recieveToken=$myPrfSeq', height:  defaultSize * 8,),),
                              ],
                            ):
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(margin: EdgeInsets.only(right: 30),
                                    width: defaultSize * 8,
                                    height: defaultSize * 10,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: (userPrfSeq == null)
                                              ? AssetImage('assets/noimage.jpg')
                                              : NetworkImage(
                                              '$url/api/mypage/images?recieveToken=$userPrfSeq')), //.
                                    ),


                                ),
                                Container(
                                  padding:  EdgeInsets.all(defaultSize * 1.2 ),
                                  margin:  EdgeInsets.only(right: defaultSize ),
                                  decoration: BoxDecoration(
                                    color: Colors.lightGreen[600],
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child:textView (defaultSize, messages.length - index -1),
                                ),
                                // Text('${index.toString()}'),
                                dataView(defaultSize, messages.length - index -1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ) : Container();
                  },
                ),
              ),
              Container(
                height: height * 0.1,
                width: width,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: width * 0.7,
                      padding: const EdgeInsets.all(2.0),
                      margin: const EdgeInsets.only(left: 40.0),
                      child: Form(
                        key: formKey,
                        child: TextFormField(
                          validator: (value){
                            if(value.trim().isEmpty){
                              return '메세지를 입력 하세요.';
                            }else{ return null;}
                          },
                          decoration: InputDecoration.collapsed(
                            hintText: '메세지를 입력 하세요.',
                          ),
                          controller: textController,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: defaultSize * 2),
                      child: FloatingActionButton(
                        backgroundColor: Colors.lightGreen[600],
                        onPressed: () => sendMessage(),
                        child: Icon(
                          Icons.send, size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  sendMessage() async{
    if (textController.text.isNotEmpty) {
      await Future.microtask((){
        if(junId == mbrId){
          print('senderID =========================== junId');
          socketIO.sendMessage(
              'send_message', json.encode(
              {
                "message": textController.text,
                "senderID" :mbrId,
                "receiverID": hanId,
                "roomCode": jobId+hanId
              }
          ));
        } else {
          print('senderID =========================== hanId');
          socketIO.sendMessage(
              'send_message', json.encode(
              {
                "message": textController.text,
                "senderID" :mbrId,
                "receiverID": junId,
                "roomCode": jobId+junId
              }
          ));
        }
        return;
      }).then((_){
        this.setState((){
          print('messages ============= 1111 $messages');
          var now = dateTimeFormat.format(DateTime.now());
          messages.add(
              {
                "message" : textController.text,
                "date" : now,
                "name": mbrId
              }
          );
          textController.clear();
        });
        print('messages ============= 2222 $messages');
        return;
      });
    }
  }

  socketStatus(dynamic data) { //소켓 연결 상태 확인 후 연결 되지 않으면 뒤로 가기
    try {
      print("Socket status: " + data);
      if(data != "connect") {
        globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
        Future.delayed(Duration(seconds: 1), (){
          return Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder: (BuildContext context) => MyHomePage(index: 2,)), (route) => false);
        });
      }
      print('====================================================================================');
      // socketIO
      socketIO.subscribe('receive_message', (jsonData) {
        print('receive_message ------------------------------------ $jsonData');
        if(!isDisposed){setState(() => messages.add(json.decode(jsonData)) );}
      }).then((value) {
        print('receive_message =========================================');
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 0),
          curve: Curves.easeOut,
        );
        return;
      });

    } catch (e) {
      print(e.toString());
      globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
      Future.delayed(Duration(seconds: 1), (){
        return Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (BuildContext context) => MyHomePage(index: 2,)), (route) => false);
      });
    }
  }

  Widget textView (defaultSize, index){
    // print('--------------------------------------------------------------');
    // print(messages[index]['message']);
    if(messages[index]['message'] == null ) {
      return Container();
    }
    if(messages[index]['message'].length > 40 ){
      return Text(
        messages[index]['message'].substring(0,16)+"\n"+ messages[index]['message'].substring(16, 33) + "\n" + messages[index]['message'].substring(33),
        style: TextStyle(color: Colors.white, fontSize: defaultSize * 1.7), );
    } else if(messages[index]['message'].length > 30 ){
      return Text(
        messages[index]['message'].substring(0,15)+"\n"+ messages[index]['message'].substring(15, 30) + "\n" + messages[index]['message'].substring(30),
        style: TextStyle(color: Colors.white, fontSize: defaultSize * 1.7), );
    } else if(messages[index]['message'].length > 10 ){
      return Text(messages[index]['message'].substring(0,10)+"\n"+ messages[index]['message'].substring(10),
        style: TextStyle(color: Colors.white, fontSize: defaultSize * 1.7), );
    } else if(messages[index]['message'].length > 20 ){
      return Text(
        messages[index]['message'].substring(0,10)+"\n"+ messages[index]['message'].substring(10, 20) + "\n" +  messages[index]['message'].substring(20),
        style: TextStyle(color: Colors.white, fontSize: defaultSize * 1.7), );
    }
    return Text(messages[index]['message'], style: TextStyle(color: Colors.white, fontSize: defaultSize * 1.7), );
  }

  Widget dataView(defaultSize, index){
    // print('date ==================================== ${messages[index]['date']}');
    var chatDate = dateFormat.format(DateTime.parse(messages[index]['date']));
    // print('chatDate ======================= $chatDate');
    var now = dateFormat.format(DateTime.now());
    // print('now =========================== $now');
    int compare = now.compareTo(chatDate); //날짜 비교 작업 오늘 날짜와 비교
    // print('compare =================== $compare');
    if (compare == 0 ){
      screenDate = timeFormat.format(DateTime.parse(messages[index]['date']));
    } else {
      screenDate = dateFormat.format(DateTime.parse(messages[index]['date']));
    }
    // print('screenDate =================== $screenDate');
    return Container(
      margin:  EdgeInsets.only(top: defaultSize * 1.1),
      child: Text(
        '${screenDate ?? ''}',
        // messages[index]['date'],
        style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.1),
      ),
    );
  }

  Future<bool> onBackPressed() => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyHomePage(index: 2,)), (route) => false);
}