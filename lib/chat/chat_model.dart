import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'dart:convert';


class ChatModel extends Model {

  SocketIO socketIO;

  void init(mbrId) {
    socketIO = SocketIOManager().createSocketIO(
        'http://192.168.1.2:3000', '/',
        query: 'mbrId=$mbrId');
    socketIO.init();

    socketIO.subscribe('receive_message', (jsonData) {
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
