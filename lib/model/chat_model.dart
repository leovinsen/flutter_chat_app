import 'package:firebase_database/firebase_database.dart';

class ChatRoomModel{

  String chatUID;
  List<String> members;
  String lastMessageSent;
  String lastMessageSentUID;
  ChatRoomModel(this.chatUID, this.members, this.lastMessageSent, this.lastMessageSentUID);


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