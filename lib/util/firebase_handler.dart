import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chat_app/model/chat_room_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';


  FirebaseDatabase db = FirebaseDatabase.instance;
  DatabaseReference _usersRef = db.reference().child('users');
  DatabaseReference _usersInfoRef = db.reference().child('usersInfo');
  DatabaseReference _usersContactRef = db.reference().child('usersContact');


  DatabaseReference _chatRef = db.reference().child('chats');
  DatabaseReference _chatMessagesRef = db.reference().child('chatMessages');
  DatabaseReference  _userChatsRef = db.reference().child('userChats');

  void enableCaching(){
    db.setPersistenceEnabled(true);
  }

//  FirebaseHandler(){
//    db.setPersistenceEnabled(true);
//    _usersRef = db.reference().child('users');
//    _usersInfoRef = db.reference().child('usersInfo');
//    _usersContactRef = db.reference().child('usersContact');
//    _chatRef = db.reference().child('chats');
//    _chatMessagesRef = db.reference().child('chatMessages');
//    _userChatsRef = db.reference().child('userChats');
//  }

  Query queryMessagesOrderByTimeAscending(String chatUID){
    return _chatMessagesRef.child(chatUID).orderByChild('messageTime');
  }

//  void enableCaching(){
//    db.setPersistenceEnabled(true);
//  }

  void createChatRoom(String senderPublicId, receiverPublicId){
    String chatUID = getChatUID(senderPublicId, receiverPublicId);

    _chatRef.child(chatUID).child('members').child(senderPublicId).set(true);
    _chatRef.child(chatUID).child('members').child(receiverPublicId).set(true);

    _userChatsRef.child(senderPublicId).child(chatUID).set(true);
    _userChatsRef.child(receiverPublicId).child(chatUID).set(true);
  }



  String getChatUID(String senderPublicId, String receiverPublicId){
    return senderPublicId.hashCode <= receiverPublicId.hashCode ? '$senderPublicId-$receiverPublicId' : '$receiverPublicId-$senderPublicId';
  }

  Future<ChatRoomData> getChatRoomModel(String chatUID) async {
    ChatRoomData chatRoom;
    DataSnapshot snapshot = await _chatRef.child(chatUID).once();
    Map<String, bool> members = Map<String, bool>.from(snapshot.value['members']);
    String messageUID = snapshot.value['lastMessageSent'];
    String lastMessage = await getChatMessage(chatUID, messageUID);
    int timeStamp = snapshot.value['lastMessageSentTime'];
    chatRoom = ChatRoomData(
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
    DataSnapshot snapshot = await _chatMessagesRef.child(chatUID).child(messageUID).once();
    return snapshot.value['message'];
  }


  Future<void> insertChatMessage(String senderId, String receiverId, String message) async {

    String chatUID = getChatUID(senderId, receiverId);

    _userChatsRef.child(senderId).update({
      chatUID : true
    });
    _userChatsRef.child(receiverId).update({
      chatUID : true
    });

    DatabaseReference newMessageRef = _chatMessagesRef.child(chatUID).push();
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

    _chatRef.child(chatUID).update({
      'members' : members,
      'lastMessageSent' : newMessageUID,
      'lastMessageSentTime' : timeStamp,
    });
  }

  Future<void> createUserAssociation(String uniqueAuthId, String publicId){
    return _usersRef.child(uniqueAuthId).set(publicId);
  }

  Future<bool> contactExists(String publicId, String contactId) async{
    DataSnapshot snapshot = await _usersContactRef.child(publicId).child(contactId).once();
    return snapshot.value != null;
  }

  Future<void> addContact(String userPublicId, String contactPublicId){
    return _usersContactRef.child(userPublicId).child(contactPublicId).push().set(contactPublicId);
  }

  Future<void> updateUsersInfo(UserData model){
    return _usersInfoRef.child(model.publicId).set(model.toJson());
  }

  Future<String> getUserPublicId(String uniqueAuthId)async {
    DataSnapshot snapshot = await _usersRef.child(uniqueAuthId).once();
    return snapshot.value;
  }

  Future<UserData> getUserModelForPublicId(String publicId) async{
    UserData model;
    DataSnapshot snapshot = await _usersInfoRef.child(publicId).once();
    model = UserData.fromSnapshot(snapshot);
    return model;

  }

  StreamSubscription<Event> contactsCallback(String publicId, Function(Event) fn) {
    return _usersContactRef
        .child(publicId).orderByKey()
        .onChildAdded
        .listen(fn);
  }

  StreamSubscription<Event>  chatRoomCallback(String publicId, Function(Event) fn){
    return _userChatsRef.child(publicId).orderByChild('lastMessageSentTime').onChildAdded.listen(fn);
  }

  StreamSubscription<Event>  newMessageCallback(String chatUID, Function(Event) fn){
    return _chatRef.child(chatUID).onValue.listen(fn);
  }



