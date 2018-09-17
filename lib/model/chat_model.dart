import 'package:firebase_database/firebase_database.dart';

class ChatRoomModel{

  String chatUID;
  List<String> members;
  String lastMessageSent;
  ChatRoomModel(this.chatUID, this.members, this.lastMessageSent);


  ChatRoomModel.fromSnapshot(DataSnapshot snapshot)
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