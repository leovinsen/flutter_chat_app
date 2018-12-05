class ChatRoomData {
  String chatUID;
  List<String> allMembersPublicId;
  String lastMessageSentUID;
  int lastMessageSentTime;

  String lastMessageSent;
  List<String> allMembers;

  ChatRoomData({this.chatUID,
    this.allMembersPublicId,
    this.allMembers,
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
