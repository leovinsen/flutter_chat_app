import 'package:firebase_database/firebase_database.dart';

class ChatRoomData{

  String chatUID;
  List<String> members;
  String lastMessageSent;
  String lastMessageSentUID;
  int lastMessageSentTime;
  ChatRoomData({this.chatUID, this.members, this.lastMessageSent, this.lastMessageSentUID, this.lastMessageSentTime});


  ChatRoomData.fromSnapshot(DataSnapshot snapshot)
      : chatUID = snapshot.key,
        members = snapshot.value['members'],
  lastMessageSent = snapshot.value['lastMessageSent'];


  toJson(){
    return {
      'members' : members,
      'lastMessageSent' : lastMessageSent
    };
  }


}