import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'dart:convert';


class ChatModel extends Model {

  SocketIO socketIO; //소켓 변수 선언

  void init(mbrId) {
    socketIO = SocketIOManager().createSocketIO( //소켓 변수에 주소, ID 데이터 입력.
        'http://192.168.1.2:3000', '/',
        query: 'mbrId=$mbrId');
    socketIO.init(); //? 이해 못함

    socketIO.subscribe('receive_message', (jsonData) { // ? 소켓을 승낙하고 받은 메세지 서버 데이터를 디코드 하여 데이터 화 하는 가정으로 이해함
      Map<String, dynamic> data = json.decode(jsonData);
      print('data ================ $data');
      // messages.add(Message(
      //     data['content'], data['senderChatID'], data['receiverChatID']));
      // notifyListeners();
    });

    socketIO.connect();
  }

  // void sendMessage(String text, String receiverChatID) {
  //   messages.add(Message(text, currentUser.chatID, receiverChatID));
  //   socketIO.sendMessage(
  //     'send_message',
  //     json.encode({
  //       'receiverChatID': receiverChatID,
  //       'senderChatID': currentUser.chatID,
  //       'content': text,
  //     }),
  //   );
  //   notifyListeners();
  // }

}
