import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
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
  chatRoom = ChatRoomModel(chatUID, members.keys.toList(), lastMessage);

  //chatRoom = ChatRoomModel.fromSnapshot(snapshot);
  return chatRoom;
}

Future<String> getChatMessage(String chatUID, String messageUID) async {
  DataSnapshot snapshot = await chatMessagesRef.child(chatUID).child(messageUID).once();
  return snapshot.value['message'];
}


Future<void> insertChatMessage(String senderId, String receiverId, String message) async {

  String chatUID = getChatUID(senderId, receiverId);
  //String chatUID = senderId.hashCode <= receiverId.hashCode ? '$senderId-$receiverId' : '$receiverId-$senderId';

  DatabaseReference newMessageRef = chatMessagesRef.child(chatUID).push();
  String newMessageUID = newMessageRef.key;

  newMessageRef.set({
    'sentBy' : senderId,
    'messageTime' : DateTime.now().millisecondsSinceEpoch.toString() ,
    //'invertedMessageTime' : (0 - DateTime.now().millisecondsSinceEpoch).toString(),
    'message' : message
  });

  chatRef.child(chatUID).child('lastMessageSent').set(newMessageUID);
//  chatRef.child(chatUID).set({
//    'lastMessageSent' : newMessageUID
//  });

  //chatRef.child('chatUID').set();

  //Parameters:
  //userModel, contactModel

  //Check in /chats/ if it has chatUID
  //if it doesnt, create record with the members,
      //Also reference this chatUID to /userChats/userUID

//  if (id.hashCode <= peerId.hashCode) {
//    groupChatId = '$id-$peerId';
//  } else {
//    groupChatId = '$peerId-$id';
//  }
  //Then, insert messageUID as LastMEssageSent

  //Insert this record to /userChats/userUID
  //


  //Insert Message to /chatMessages/
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

dynamic onNewContactsCallback(String publicId, Function(Event) fn) {
  return usersContactRef
      .child(publicId)
      .onChildAdded
      .listen(fn);
}

dynamic onNewChatCallback(String publicId, Function(Event) fn){
  return userChatsRef.child(publicId).onChildAdded.listen(fn);
}