class ChatRoomData {
  String chatUID;
  List<String> allMembersPublicId;
  String lastMessageSent;
  String lastMessageSentUID;
  int lastMessageSentTime;

  ChatRoomData(
      {this.chatUID,
      this.allMembersPublicId,
      this.lastMessageSent,
      this.lastMessageSentUID,
      this.lastMessageSentTime});

//
//  ChatRoomData.fromSnapshot(DataSnapshot snapshot)
//      : chatUID = snapshot.key,
//        members = snapshot.value['members'],
//  lastMessageSent = snapshot.value['lastMessageSent'];

  toJson() {
    return {'members': allMembersPublicId, 'lastMessageSent': lastMessageSent};
  }
}
