import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/data/repository.dart';
import 'package:flutter_chat_app/model/chat_room_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:scoped_model/scoped_model.dart';

enum AuthStatus {
  notSignedIn,
  incompleteRegistration,
  signedIn,
}

AuthStatus enumFromString(String str){
  return AuthStatus.values.firstWhere((elem) => elem.toString() == str, orElse: ()=> null);
}

class AppData extends Model {

  Repository repo;
  bool ready = false;

  AuthStatus _status;
  AuthStatus get status => _status;

  List<StreamSubscription<Event>> _chatRoomSubs = [];
  StreamSubscription<Event> _onNewContactsSub;
  StreamSubscription<Event> _onNewChatSub;
  StreamSubscription<Event> _onProfileUpdate;


  String _publicId;
  String _token;
  String _thumbUrl;
  String _displayName;


  String get publicId => _publicId;
  String get thumbUrl => _thumbUrl;

  String get displayName => _displayName;


  List<UserData> _contactsData = [];
  List<ChatRoomData> _chatRoomsData = [];

  List<UserData> get contactsData => _contactsData;

  List<ChatRoomData> get chatRoomData => _chatRoomsData;

  AppData(){
    initialize();
  }

  Future initialize() async {
    repo = Repository();
    await repo.init();
    _token = await repo.getUserAuthToken();
    if(_token != null) {
      _publicId = await repo.getUserPublicId(_token);
      if(_publicId != null){
        _displayName = await repo.getUserDisplayName();
        print('displayName from repo: $_displayName');
        _status = AuthStatus.signedIn;
      } else {
        _status = AuthStatus.incompleteRegistration;
      }

    } else {
      _status = AuthStatus.notSignedIn;
    }
    ready = true;
    notifyListeners();
  }

  Future<bool> finishRegistration(String publicId, String displayName) async {
    try {
      await repo.finishRegistration(publicId, displayName);
      _publicId = publicId;
      _displayName = displayName;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future signOut() async {
    await repo.signOut();
    _status = AuthStatus.notSignedIn;
    _contactsData.clear();
    _chatRoomsData.clear();
    _publicId = null;
    _displayName = null;
    _thumbUrl = null;
    notifyListeners();
  }


  cleanup() {

  }




















//  final FirebaseDatabase _db = FirebaseDatabase.instance;
//
//  List<StreamSubscription<Event>> _chatRoomSubs = [];
//  StreamSubscription<Event> _onNewContactsSub;
//  StreamSubscription<Event> _onNewChatSub;
//  StreamSubscription<Event> _onProfileUpdate;
//
////  String _userPublicId;
////  String _userDisplayName;
////  String _userThumbUrl;
//  List<UserData> _contactsData = [];
//  List<ChatRoomData> _chatRoomsData = [];
//
////  String get userPublicId => _userPublicId;
////  String get userDisplayName => _userDisplayName;
////  String get userThumbUrl => _userThumbUrl;
//  List<UserData> get contactsData => _contactsData;
//  List<ChatRoomData> get chatRoomData => _chatRoomsData;
//
////  initUserModel(String publicId) async {
////    _userPublicId = publicId;
////
////    var snapshot = await _db.reference().child('usersInfo/$publicId').once();
////    _userDisplayName = snapshot.value['displayName'];
////    _userThumbUrl = snapshot.value['thumbUrl'];
////    notifyListeners();
////  }
//
//  /*
//    Callback for branch userChats
//    Retrieves active chats which involves the user
//    Then, retrieve the information about the chat rooms
//   */
//  void onNewChat(Event event) async {
//    //Chat Room ID
//    String chatUID = event.snapshot.key;
//
//    var snapshot = await _db.reference().child('chats/$chatUID').once();
//
//    List allMembersPublicId =
//        Map<String, bool>.from(snapshot.value['members']).keys.toList();
//
//    ///Note: Might need to add await to getUserDisplayName
//    List<String> allMembersDisplayName = [];
//
//    for (String id in allMembersPublicId) {
//      allMembersDisplayName.add(await getUserDisplayName(id));
//    }
//
//    String lastMessageSentID = snapshot.value['lastMessageSent'];
//    String lastMessageSent = await getChatMessage(chatUID, lastMessageSentID);
//    int lastMessageSentTime = snapshot.value['lastMessageSentTime'];
//
//    _chatRoomsData.add(ChatRoomData(
//      chatUID: chatUID,
//      allMembersPublicId: allMembersPublicId,
//      allMembers: allMembersDisplayName,
//      lastMessageSentUID: lastMessageSentID,
//      lastMessageSent: lastMessageSent,
//      lastMessageSentTime: lastMessageSentTime,
//    ));
//
//    _chatRoomSubs.add(newMessageCallback(chatUID, onChatNewMessage));
//    notifyListeners();
//  }
//
//  Future<String> getChatMessage(String chatUID, String messageUID) async {
//    DataSnapshot snapshot =
//        await _db.reference().child('chatMessages/$chatUID/$messageUID').once();
//    return snapshot.value['message'];
//  }
//
//  Future<String> getUserDisplayName(String publicId) async {
//    DataSnapshot snapshot =
//        await _db.reference().child('usersInfo/$publicId/displayName').once();
//    return snapshot.value;
//  }
//
//  ///TODO: FIX THIS
//  void onChatNewMessage(Event event) async {
//    print(_chatRoomsData);
//    ChatRoomData chatRoom = _chatRoomsData.singleWhere((chatRoom) {
//      return event.snapshot.key == chatRoom.chatUID;
//    });
//    if (chatRoom.lastMessageSentUID !=
//        event.snapshot.value['lastMessageSent']) {
//      String newMessage = await getChatMessage(
//          chatRoom.chatUID, event.snapshot.value['lastMessageSent']);
//      chatRoom.lastMessageSent = newMessage;
//      notifyListeners();
//    } else {
//      print('AppData, OnChatNewMessage ERROR: ' +
//          event.snapshot.value['lastMessageSent']);
//    }
//  }
//
//  void retrieveContactInfo(Event event) async {
//    String contactId = event.snapshot.key;
//    print('Adding contact named $contactId');
//
//    DataSnapshot snapshot =
//        await _db.reference().child('usersInfo/$contactId').once();
//    _contactsData.add(UserData.fromSnapshot(snapshot));
//
//  }
//
//  void onProfileUpdate(Event event) async {
//
//    var val = event.snapshot.value;
//    print('onProfileUpdate: $val');
//    switch(event.snapshot.key){
//      case "thumbUrl":
//        _userThumbUrl = val;
//        break;
//      case "displayName":
//        _userDisplayName = val;
//        break;
//    }
//
//    notifyListeners();
//  }
//
//  void initSubscriptions() {
//    print("Initiating Subscriptions");
//    var repo = Repository.get();
//    repo.getUserAuthToken().then((token) async {
//      String publicId = await repo.getUserPublicId(token);
//      _onNewContactsSub = contactsCallback(publicId, retrieveContactInfo);
//      _onNewChatSub = chatRoomCallback(publicId, onNewChat);
//      _onProfileUpdate = _db.reference().child('usersInfo/$publicId').onChildChanged.listen( onProfileUpdate);
//    });
////    _onNewContactsSub = contactsCallback(Repository.get().getUserPublicId(await ), retrieveContactInfo);
////    _onNewChatSub = chatRoomCallback(userPublicId, onNewChat);
////    _onProfileUpdate = _db.reference().child('usersInfo/$userPublicId').onChildChanged.listen( onProfileUpdate);
//  }
//
//  void cancelSubscriptions() {
//    print("Cancelling Subscriptions");
//    _onNewContactsSub.cancel();
//    _onNewChatSub.cancel();
//    _onProfileUpdate.cancel();
//    _chatRoomSubs.forEach((sub) {
//      sub.cancel();
//    });
//  }
//
//  StreamSubscription<Event> contactsCallback(
//      String publicId, Function(Event) fn) {
//    return _db
//        .reference()
//        .child('usersContact/$publicId')
//        .onChildAdded
//        .listen(fn);
//  }
//
//  StreamSubscription<Event> chatRoomCallback(
//      String publicId, Function(Event) fn) {
//    return _db
//        .reference()
//        .child('userChats/$publicId')
//        .orderByChild('lastMessageSentTime')
//        .onChildAdded
//        .listen(fn);
//  }
//
//  StreamSubscription<Event> newMessageCallback(
//      String chatUID, Function(Event) fn) {
//    return _db.reference().child('chats/$chatUID').onValue.listen(fn);
//  }
//

//
  static AppData of(BuildContext context) => ScopedModel.of<AppData>(context);
}
