class ChatRoomData {
  static final String kChatId = 'chatId';
  static final String kAllMembersPublicId = 'allMembersPublicId';
  static final String kAllMembersDisplayName = 'allMembersName';
  static final String kLastMessageSentId = 'lastMessageId';
  static final String kLastMessageSent = 'lastMessage';
  static final String kLastMessageTime = 'lastMessageTime';

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

  Map<String, dynamic> toJson() {
    return {
      kChatId : chatUID,
      kAllMembersPublicId: allMembersPublicId.toString(),
      kAllMembersDisplayName : allMembers.toString(),
      kLastMessageSentId : lastMessageSentUID,
      kLastMessageSent: lastMessageSent,
      kLastMessageTime : lastMessageSentTime,
    };
  }
}
