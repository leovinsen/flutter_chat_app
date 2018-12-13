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
      print('Auth.currentUser() returns null. User is not signed in');
      _status = AuthStatus.notSignedIn;
    }
    ready = true;
    notifyListeners();
  }


  ///Called when user signs in through Login Page
  Future signIn(String email, String password){
    ///Do Error handling, rseuslt message etc here
    repo.signIn(email, password);
  }


  ///Called when user registers a new account in LoginPage
  Future<bool> registerNew(String email, String password) async {
    ///Auth Status etc
    ///Do Error handling, rseuslt message etc here
    String token = await repo.registerNewAccount(email, password);
    return true;
  }

  ///Called when user registers a publicID and Display Name in AdditionalInfoScreen
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

  ///Called when user signs out from the application
  ///This deletes all user data and cache
  ///And also clears variables from memory
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

  void initSubscriptions() {
    print("Initiating Subscriptions");
    _onNewContactsSub = repo.newContactListener(publicId, retrieveContactInfo);
    _onNewChatSub = repo.newChatRoomListener(publicId, getChatRoomData);
    _onProfileUpdate = repo.onProfileUpdate(publicId, updateUserProfile);
  }

  ///Function that is called when a new chat room is found in user's chat rooms branch
  void getChatRoomData(Event event) async {
    //Chat Room ID
    String chatUID = event.snapshot.key;

    _chatRoomsData.add(await repo.getChatRoom(chatUID));
    _chatRoomSubs.add( repo.newMessagesListener(chatUID, updateLastMessageOnChatRoom));
    notifyListeners();

  }

  ///TODO: FIX THIS
  void updateLastMessageOnChatRoom(Event event) async {
    ChatRoomData chatRoom = _chatRoomsData.singleWhere((chatRoom) {
      return event.snapshot.key == chatRoom.chatUID;
    });

    String newMessageId = event.snapshot.value['lastMessageSent'];

    ///Update the latest message info on chat room
    if (chatRoom.lastMessageSentUID != newMessageId) {
      String newMessage = await repo.getChatMessage(chatRoom.chatUID, newMessageId);
      chatRoom.lastMessageSent = newMessage;
      notifyListeners();
    } else {
      print('AppData, OnChatNewMessage ERROR: ' +
          event.snapshot.value['lastMessageSent']);
    }
  }

  void updateUserProfile(Event event) async {

    var val = event.snapshot.value;
    switch(event.snapshot.key){
      case "thumbUrl":
        _thumbUrl = val;
        break;
      case "displayName":
        _displayName = val;
        break;
    }
    notifyListeners();
  }

  void retrieveContactInfo(Event event) async {
    String contactId = event.snapshot.key;
    print('Adding contact named $contactId');
    _contactsData.add(await repo.getUserDataFor(contactId));

  }

  void cancelSubscriptions() {
    print("Cancelling Subscriptions");
    _onNewContactsSub.cancel();
    _onNewChatSub.cancel();
    _onProfileUpdate.cancel();
    _chatRoomSubs.forEach((sub) {
      sub.cancel();
    });
  }

  static AppData of(BuildContext context) => ScopedModel.of<AppData>(context);
}
