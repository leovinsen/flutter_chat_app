import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/chat_room_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:scoped_model/scoped_model.dart';

class AppData extends Model {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  List<StreamSubscription<Event>> _chatRoomSubs = [];
  StreamSubscription<Event> _onNewContactsSub;
  StreamSubscription<Event> _onNewChatSub;

  String _userPublicId;
  String _userDisplayName;
  String _userThumbUrl;

  String get userPublicId => _userPublicId;

  String get userDisplayName => _userDisplayName;

  String get userThumbUrl => _userThumbUrl;

  List<UserData> _contactsData = [];
  List<ChatRoomData> _chatRoomsData = [];

  List<UserData> get contactsData => _contactsData;

  List<ChatRoomData> get chatRoomData => _chatRoomsData;

  initUserModel(String publicId) async {
    _userPublicId = publicId;

//
//    ///Retrieve userData from cache
//    String displayName = CacheHandler.getUserDisplayName();
//    String thumbUrl = CacheHandler.getUserThumbUrl();
//
//    _userData = UserData(publicId, displayName, thumbUrl);
//    notifyListeners();
    var snapshot = await _db.reference().child('usersInfo/$publicId').once();
    _userDisplayName = snapshot.value['displayName'];
    _userThumbUrl = snapshot.value['thumbUrl'];
    notifyListeners();
  }

  /*
    Callback for branch userChats
    Retrieves active chats which involves the user
    Then, retrieve the information about the chat rooms
   */
  void onNewChat(Event event) async {
    //Chat Room ID
    String chatUID = event.snapshot.key;
    print('onNewChat: $chatUID');

    var snapshot = await _db.reference().child('chats/$chatUID').once();

    List allMembersPublicId =
        Map<String, bool>.from(snapshot.value['members']).keys.toList();

    ///Note: Might need to add await to getUserDisplayName
    List<String> allMembersDisplayName = [];

    for (String id in allMembersPublicId) {
      allMembersDisplayName.add(await getUserDisplayName(id));
    }

    String lastMessageSentID = snapshot.value['lastMessageSent'];
    String lastMessageSent = await getChatMessage(chatUID, lastMessageSentID);
    int lastMessageSentTime = snapshot.value['lastMessageSentTime'];

    _chatRoomsData.add(ChatRoomData(
      chatUID: chatUID,
      allMembersPublicId: allMembersPublicId,
      allMembers: allMembersDisplayName,
      lastMessageSentUID: lastMessageSentID,
      lastMessageSent: lastMessageSent,
      lastMessageSentTime: lastMessageSentTime,
    ));

    _chatRoomSubs.add(newMessageCallback(chatUID, onChatNewMessage));
    notifyListeners();
  }

  Future<String> getChatMessage(String chatUID, String messageUID) async {
    DataSnapshot snapshot =
        await _db.reference().child('chatMessages/$chatUID/$messageUID').once();
    return snapshot.value['message'];
  }

  Future<String> getUserDisplayName(String publicId) async {
    DataSnapshot snapshot =
        await _db.reference().child('usersInfo/$publicId/displayName').once();
    return snapshot.value;
  }

  ///TODO: FIX THIS
  void onChatNewMessage(Event event) async {
    print(_chatRoomsData);
    ChatRoomData chatRoom = _chatRoomsData.singleWhere((chatRoom) {
      return event.snapshot.key == chatRoom.chatUID;
    });
    if (chatRoom.lastMessageSentUID !=
        event.snapshot.value['lastMessageSent']) {
      String newMessage = await getChatMessage(
          chatRoom.chatUID, event.snapshot.value['lastMessageSent']);
      chatRoom.lastMessageSent = newMessage;
      notifyListeners();
    } else {
      print('AppData, OnChatNewMessage ERROR: ' +
          event.snapshot.value['lastMessageSent']);
    }
  }

  void onNewContact(Event event) async {
    Map map = event.snapshot.value;
    String contactId = map.values.first.toString();
    print('OnNewContact: $contactId');
    DataSnapshot snapshot =
        await _db.reference().child('usersInfo/$contactId').once();
    _contactsData.add(UserData.fromSnapshot(snapshot));
//    firebaseHandler.getUserModelForPublicId(contactId).then((model){
//      _contactsData.add(model);
//      notifyListeners();
//    });
  }

//  Future<UserData> getUserModelForPublicId(String publicId) async{
//    UserData model;
//    DataSnapshot snapshot = await _usersInfoRef.child(publicId).once();
//    model = UserData.fromSnapshot(snapshot);
//    return model;
//
//  }

  void initSubscriptions() {
    print("Initiating Subscriptions");
    _onNewContactsSub = contactsCallback(userPublicId, onNewContact);
    _onNewChatSub = chatRoomCallback(userPublicId, onNewChat);
  }

  void cancelSubscriptions() {
    print("Cancelling Subscriptions");
    _onNewContactsSub.cancel();
    _onNewChatSub.cancel();
    _chatRoomSubs.forEach((sub) {
      sub.cancel();
    });
  }

  StreamSubscription<Event> contactsCallback(
      String publicId, Function(Event) fn) {
    return _db
        .reference()
        .child('usersContact/$publicId')
        .orderByKey()
        .onChildAdded
        .listen(fn);
  }

  StreamSubscription<Event> chatRoomCallback(
      String publicId, Function(Event) fn) {
    return _db
        .reference()
        .child('userChats/$publicId')
        .orderByChild('lastMessageSentTime')
        .onChildAdded
        .listen(fn);
  }

  StreamSubscription<Event> newMessageCallback(
      String chatUID, Function(Event) fn) {
    return _db.reference().child('chats/$chatUID').onValue.listen(fn);
  }

  cleanup() {
    _contactsData.clear();
    _chatRoomsData.clear();
    _userPublicId = null;
    _userDisplayName = null;
    _userThumbUrl = null;
    notifyListeners();
  }

  static AppData of(BuildContext context) => ScopedModel.of<AppData>(context);
}
