import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chat_app/model/cache_handler.dart';
import 'package:flutter_chat_app/model/chat_model.dart';
import 'package:flutter_chat_app/model/user_model.dart';

FirebaseDatabase db = FirebaseDatabase.instance;
DatabaseReference usersRef = db.reference().child('users');
DatabaseReference usersInfoRef = db.reference().child('usersInfo');
DatabaseReference usersContactRef = db.reference().child('usersContact');


DatabaseReference chatRef = db.reference().child('chats');
DatabaseReference chatMessagesRef = db.reference().child('chatMessages');
DatabaseReference userChatsRef = db.reference().child('userChats');

void enableCaching(){
  db.setPersistenceEnabled(true);
}

void createChatRoom(String senderPublicId, receiverPublicId){
  String chatUID = getChatUID(senderPublicId, receiverPublicId);

  chatRef.child(chatUID).child('members').child(senderPublicId).set(true);
  chatRef.child(chatUID).child('members').child(receiverPublicId).set(true);

  userChatsRef.child(senderPublicId).child(chatUID).set(true);
  userChatsRef.child(receiverPublicId).child(chatUID).set(true);
}



String getChatUID(String senderPublicId, String receiverPublicId){
  return senderPublicId.hashCode <= receiverPublicId.hashCode ? '$senderPublicId-$receiverPublicId' : '$receiverPublicId-$senderPublicId';
}

Future<ChatRoomModel> getChatRoomModel(String chatUID) async {
  ChatRoomModel chatRoom;
  DataSnapshot snapshot = await chatRef.child(chatUID).once();
  Map<String, bool> members = Map<String, bool>.from(snapshot.value['members']);
  String messageUID = snapshot.value['lastMessageSent'];
  String lastMessage = await getChatMessage(chatUID, messageUID);
  int timeStamp = snapshot.value['lastMessageSentTime'];
  chatRoom = ChatRoomModel(
      chatUID:  chatUID,
      members:  members.keys.toList(),
      lastMessageSent: lastMessage,
      lastMessageSentUID: messageUID,
      lastMessageSentTime:  timeStamp)
  ;

  //chatRoom = ChatRoomModel.fromSnapshot(snapshot);
  return chatRoom;
}

Future<String> getChatMessage(String chatUID, String messageUID) async {
  DataSnapshot snapshot = await chatMessagesRef.child(chatUID).child(messageUID).once();
  return snapshot.value['message'];
}


Future<void> insertChatMessage(String senderId, String receiverId, String message) async {

  String chatUID = getChatUID(senderId, receiverId);

  userChatsRef.child(senderId).update({
    chatUID : true
  });
  userChatsRef.child(receiverId).update({
    chatUID : true
  });

  DatabaseReference newMessageRef = chatMessagesRef.child(chatUID).push();
  String newMessageUID = newMessageRef.key;

  int timeStamp = DateTime.now().millisecondsSinceEpoch;
  
  newMessageRef.update({
    'sentBy' : senderId,
    'messageTime' : timeStamp ,
    'message' : message
  });

  Map members = {
    senderId : true,
    receiverId : true
  };

  chatRef.child(chatUID).update({
    'members' : members,
    'lastMessageSent' : newMessageUID,
    'lastMessageSentTime' : timeStamp,
  });
}

Future<void> createUserAssociation(String uniqueAuthId, String publicId){
  return usersRef.child(uniqueAuthId).set(publicId);
}

Future<bool> contactExists(String publicId, String contactId) async{
  DataSnapshot snapshot = await usersContactRef.child(publicId).child(contactId).once();
  return snapshot.value != null;
}

Future<void> addContact(String userPublicId, String contactPublicId){
  return usersContactRef.child(userPublicId).child(contactPublicId).push().set(contactPublicId);
}

Future<void> updateUsersInfo(UserModel model){
  return usersInfoRef.child(model.publicId).set(model.toJson());
}

Future<String> getUserPublicId(String uniqueAuthId)async {
  DataSnapshot snapshot = await usersRef.child(uniqueAuthId).once();
  return snapshot.value;
}

//Future<bool> isUserFullyRegistered(String uniqueAuthId) async {
//  DataSnapshot snapshot = await getUserPublicId(uniqueAuthId);
//  return snapshot.value != null;
//}

Future<UserModel> getUserModelForPublicId(String publicId) async{
  UserModel model;
  DataSnapshot snapshot = await usersInfoRef.child(publicId).once();
  model = UserModel.fromSnapshot(snapshot);
  return model;

}

StreamSubscription<Event> contactsCallback(String publicId, Function(Event) fn) {
  return usersContactRef
      .child(publicId).orderByKey()
      .onChildAdded
      .listen(fn);
}

StreamSubscription<Event>  chatRoomCallback(String publicId, Function(Event) fn){
  return userChatsRef.child(publicId).orderByChild('lastMessageSentTime').onChildAdded.listen(fn);
}

StreamSubscription<Event>  newMessageCallback(String chatUID, Function(Event) fn){
  return chatRef.child(chatUID).onValue.listen(fn);
}