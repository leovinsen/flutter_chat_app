import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chat_app/data/cache_database.dart';
import 'package:flutter_chat_app/data/cache_sharedPrefs.dart';
import 'package:flutter_chat_app/data/network_handler.dart';
import 'package:flutter_chat_app/model/auth.dart';
import 'package:flutter_chat_app/model/chat_room_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';

enum AuthStatus {
  notSignedIn,
  incompleteRegistration,
  signedIn,
}

AuthStatus enumFromString(String str){
  return AuthStatus.values.firstWhere((elem) => elem.toString() == str, orElse: ()=> null);
}

class Repository  {

  static final Repository _repo = Repository._internal();

  CacheDatabase database;
  CacheSharedPrefs sharedPrefs;
  NetworkHandler network;
  Auth auth;

  List<StreamSubscription<Event>> _chatRoomSubs = [];
  StreamSubscription<Event> _onNewContactsSub;
  StreamSubscription<Event> _onNewChatSub;
  StreamSubscription<Event> _onProfileUpdate;

  String _publicId;
  String _token;
  String _thumbUrl;
  String _displayName;

  String get thumbUrl => _thumbUrl;
  String get displayName => _displayName;


  List<UserData> _contactsData = [];
  List<ChatRoomData> _chatRoomsData = [];

  List<UserData> get contactsData => _contactsData;

  List<ChatRoomData> get chatRoomData => _chatRoomsData;


  static Repository get() {
    return _repo;
  }

  Repository._internal() {
    database = CacheDatabase.get();
    sharedPrefs = CacheSharedPrefs.instance;
    auth = Auth.instance;
    network = NetworkHandler.instance;
  }

  Future signOut() async {
    auth.signOut().then((a) {
      sharedPrefs.destroy();
      //Clear database
      //Release subscriptions
    });
  }

  Future<bool> loadCache() async {
    print('Loading Cache...');
    _publicId = await sharedPrefs.getUserPublicId();
    if(_publicId != null) {
      UserData user = await database.getUserData(_publicId);
      if (user != null) {
        _publicId = user.publicId;
        _displayName = user.displayName;
        _thumbUrl = user.thumbUrl;
        print('Successfully loaded cache.');
        return true;
      }
    }
    print('No data cached.');
    return false;
  }

  Future<AuthStatus> authenticate() async {
    print('Authenticating user....');
    //AuthStatus status = enumFromString(await sharedPrefs.getUserAuthStatus());
    AuthStatus status;

      print('a');
      String token = await getUserAuthToken();
      if (token == null) {
        print('b');
        status = AuthStatus.notSignedIn;
      }
      else {
        //First, save into cache
        await sharedPrefs.updateUserAuthToken(token);
        print('c');
        String publicId = await getUserPublicId(token);
        if(publicId == null){
          status = AuthStatus.incompleteRegistration;
        } else {
          status = AuthStatus.signedIn;
          await sharedPrefs.updateUserPublicId(publicId);
        }
//        status =
//        (publicId == null) ? AuthStatus.incompleteRegistration : AuthStatus
//            .signedIn;
      }

    print('Authenticate result: ${status.toString()}');
    return status;
  }

  Future<String> getUserAuthToken() async {
    if (_token == null) {
      String token = await sharedPrefs.getUserAuthToken();
      print('token: $token');
      if (token == null)
        token = await auth.currentUser();
      print('token2: $token');
      _token = token;
    }
    return _token;
  }

  Future<String> getUserPublicId(String token) async {
    if (_publicId == null) {
      String publicId = await sharedPrefs.getUserPublicId();
      print('sharedPrefs: $publicId');
      if (publicId == null)
        publicId = await network.getPublicId(token);
      _publicId = publicId;
    }
    print('publicId networkFetch: $_publicId');
    return _publicId;
  }

  Future<String> getUserDisplayName(){

  }

  Future finishRegistration(String publicId, String displayName) async {
    await network.registerPublicId(await getUserAuthToken(), publicId);
    await network.updateUserInfo(
        {UserData.kPublicId: publicId, UserData.kDisplayName: displayName},
        publicId);
    //Update cache

    await database.insert(UserData(publicId,displayName,null));
  }

  ///TEMPORARY ONLY.
  String getUserPublicIdFromMemory() {
    return _publicId;
  }


  void initSubscriptions() {
    getUserAuthToken().then((token) async {
      String publicId = await getUserPublicId(token);
      _onNewContactsSub =
          network.contactsCallback(publicId, retrieveContactInfo);
      _onNewChatSub = network.chatRoomCallback(publicId, onNewChat);
      _onProfileUpdate =
          network.profileUpdateListener(publicId, onProfileUpdate);
    });
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

  void onChatNewMessage(Event event) async {
    ChatRoomData chatRoom = _chatRoomsData.singleWhere((chatRoom) {
      return event.snapshot.key == chatRoom.chatUID;
    });
    if (chatRoom.lastMessageSentUID !=
        event.snapshot.value['lastMessageSent']) {
      String newMessage = await network.getChatMessage(
          chatRoom.chatUID, event.snapshot.value['lastMessageSent']);
      chatRoom.lastMessageSent = newMessage;
      //notifyListeners();
    } else {
      print('REPOSITORY, OnChatNewMessage ERROR: ' +
          event.snapshot.value['lastMessageSent']);
    }
  }

  void retrieveContactInfo(Event event) async {
    String contactId = event.snapshot.key;
    print('Adding contact named $contactId');
    UserData user = await database.getUserData(contactId);
    if (user == null) {
      DataSnapshot snapshot = await network.getUserDataSnapshot(contactId);
      user = UserData.fromSnapshot(snapshot);
    }
    _contactsData.add(user);
  }

  void onProfileUpdate(Event event) async {
    var val = event.snapshot.value;
    print('onProfileUpdate: $val');
    switch (event.snapshot.key) {
      case "thumbUrl":
        _thumbUrl = val;
        break;
      case "displayName":
        _displayName = val;
        break;
    }

//    notifyListeners();
  }

/*
    Callback for branch userChats
    Retrieves active chats which involves the user
    Then, retrieve the information about the chat rooms
   */
  void onNewChat(Event event) async {
    //Chat Room ID
    String chatUID = event.snapshot.key;

    var snapshot = await network.getChatRoomSnapshot(chatUID);

    List allMembersPublicId =
    Map<String, bool>.from(snapshot.value['members']).keys.toList();

    ///Note: Might need to add await to getUserDisplayName
    List<String> allMembersDisplayName = [];

    for (String id in allMembersPublicId) {
      allMembersDisplayName.add(await network.getUserDisplayName(id));
    }

    String lastMessageSentID = snapshot.value['lastMessageSent'];
    String lastMessageSent = await network.getChatMessage(
        chatUID, lastMessageSentID);
    int lastMessageSentTime = snapshot.value['lastMessageSentTime'];

    _chatRoomsData.add(ChatRoomData(
      chatUID: chatUID,
      allMembersPublicId: allMembersPublicId,
      allMembers: allMembersDisplayName,
      lastMessageSentUID: lastMessageSentID,
      lastMessageSent: lastMessageSent,
      lastMessageSentTime: lastMessageSentTime,
    ));

    // Future<UserData> getUserDataFor
//
//  ///Called when app is first started,
//  ///determine whether user is signed in or not
//  Future<AuthStatus> authenticate() async {
//    String uniqueAuthId = await Auth.instance.currentUser();
//    if(uniqueAuthId != null){
//      var snapshot = await FirebaseDatabase.instance.reference().child('users/$uniqueAuthId').once();
//      String publicId = snapshot.value;
//      return publicId == null ? AuthStatus.incompleteRegistration : AuthStatus.signedIn;
//    } else {
//      return AuthStatus.notSignedIn;
//    }
//  }

//  _uniqueAuthId = await getUserAuthToken();
//  if(_uniqueAuthId != null) {
//  _publicId = await getUserPublicId();
//  _authStatus = _publicId == null ? AuthStatus.incompleteRegistration : AuthStatus.signedIn;
//  } else {
//  _authStatus =AuthStatus.notSignedIn;
//  }

//  Future<String> getUserAuthToken() async {
//    //Get user Auth ID from local storage
//    String uniqueAuthId = CacheHandler.getUserFirebaseAuthId();
//
//    //If not found, try online
//    if (uniqueAuthId == null) uniqueAuthId = await auth.currentUser();
//
//    return uniqueAuthId;
//  }

//  ///TODO: Change to Future<String>
//  Future<String> getUserPublicId() async {
//    //String _publicId = CacheHandler.getUserPublicId();
//
//    if (_publicId == null){
//      var db = FirebaseDatabase.instance;
//      var usersBranch = db.reference().child('users');
//      DataSnapshot snapshot = await usersBranch.child(_uniqueAuthId).once();
//      _publicId = snapshot.value;
//    }
//    return _publicId ?? "";
//  }


  }
}