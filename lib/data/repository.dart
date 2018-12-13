import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chat_app/data/cache_database.dart';
import 'package:flutter_chat_app/data/cache_sharedPrefs.dart';
import 'package:flutter_chat_app/data/network_handler.dart';
import 'package:flutter_chat_app/model/auth.dart';
import 'package:flutter_chat_app/model/chat_room_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';
//
//enum AuthStatus {
//  notSignedIn,
//  incompleteRegistration,
//  signedIn,
//}
//
//AuthStatus enumFromString(String str){
//  return AuthStatus.values.firstWhere((elem) => elem.toString() == str, orElse: ()=> null);
//}

class Repository  {

  CacheDatabase database;
  CacheSharedPrefs sharedPrefs;
  NetworkHandler network;
  Auth auth;

  Repository(){
    database = CacheDatabase();
    sharedPrefs = CacheSharedPrefs();
    auth = Auth.instance;
    network = NetworkHandler.instance;
  }

  Future init() async {
    print('Initializing Repository');
    await sharedPrefs.init();
  }

  Future<String> registerNewAccount(String email, String password) async{
    return await auth.createUser(email, password);
  }

  Future signIn(String email, String password){
    auth.signIn(email, password);
  }

  Future signOut() async {
    auth.signOut().then((a) {
      sharedPrefs.destroy();
      database.delete();
      print('Successfully signed out.');
    });
  }
  Future<String> getUserAuthToken() async {
    String token;
    token = await sharedPrefs.getUserAuthToken();
    if (token == null) {
      print('User auth token not found in SharedPrefs');
      token = await auth.currentUser();
      sharedPrefs.updateUserAuthToken(token);
    }
      return token;
    }


  Future<String> getUserPublicId(String token) async {
    String publicId = await sharedPrefs.getUserPublicId();
    print('sharedPrefs: $publicId');
    if (publicId == null){
      publicId = await network.getPublicId(token);
      sharedPrefs.updateUserPublicId(publicId);
      print('publicId networkFetch: $publicId');
    }
    return publicId;
  }

  Future<String> getUserDisplayName() async {
    String name = await sharedPrefs.getUserDisplayName();
    return name;
  }

  Future finishRegistration(String publicId, String displayName) async {
    try {
      await network.registerPublicId(await getUserAuthToken(), publicId);
      await network.updateUserInfo(
          {UserData.kPublicId: publicId, UserData.kDisplayName: displayName},
          publicId);

      //Update cache
      await database.insert(UserData(publicId, displayName, null));
      await sharedPrefs.updateUserPublicId(publicId);
      await sharedPrefs.updateUserDisplayName(displayName);
    } catch(e) {
      throw Exception(e.toString());
    }
  }

//  void initSubscriptions() {
//    getUserAuthToken().then((token) async {
//      String publicId = await getUserPublicId(token);
//      _onNewContactsSub =
//          network.contactsCallback(publicId, retrieveContactInfo);
//      _onNewChatSub = network.chatRoomCallback(publicId, onNewChat);
//      _onProfileUpdate =
//          network.profileUpdateListener(publicId, onProfileUpdate);
//    });
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

  StreamSubscription<Event> newMessagesListener(String chatRoomId, Function fn)  {
    return network.newMessageCallback(chatRoomId, fn);
  }

  StreamSubscription<Event> newContactListener(String userId, Function fn) {
    return network.contactsCallback(userId, fn);
  }

  StreamSubscription<Event> newChatRoomListener(String userId, Function fn) {
    return network.chatRoomCallback(userId, fn);
  }

  StreamSubscription<Event> onProfileUpdate(String userId,Function fn) {
    return network.profileUpdateListener(userId, fn);
  }

  Future<UserData> getUserDataFor(String publicId) async {
    //Check Cache first
//    UserData user;
//    user = await database.getUserData(publicId);

    //If not found go online

    UserData user = await network.getUserData(publicId);
    database.update(user);

    return user;
  }

//  void onChatNewMessage(Event event) async {
//    ChatRoomData chatRoom = _chatRoomsData.singleWhere((chatRoom) {
//      return event.snapshot.key == chatRoom.chatUID;
//    });
//    if (chatRoom.lastMessageSentUID !=
//        event.snapshot.value['lastMessageSent']) {
//      String newMessage = await network.getChatMessage(
//          chatRoom.chatUID, event.snapshot.value['lastMessageSent']);
//      chatRoom.lastMessageSent = newMessage;
//      //notifyListeners();
//    } else {
//      print('REPOSITORY, OnChatNewMessage ERROR: ' +
//          event.snapshot.value['lastMessageSent']);
//    }
//  }

//  void retrieveContactInfo(Event event) async {
//    String contactId = event.snapshot.key;
//    print('Adding contact named $contactId');
//    UserData user = await database.getUserData(contactId);
//    if (user == null) {
//      DataSnapshot snapshot = await network.getUserDataSnapshot(contactId);
//      user = UserData.fromSnapshot(snapshot);
//    }
//    _contactsData.add(user);
//  }

//  void onProfileUpdate(Event event) async {
//    var val = event.snapshot.value;
//    print('onProfileUpdate: $val');
////    switch (event.snapshot.key) {
////      case "thumbUrl":
////        _thumbUrl = val;
////        break;
////      case "displayName":
////        _displayName = val;
////        break;
////    }
//
////    notifyListeners();
//  }

  Future<String> getChatMessage(String chatRoomId, String messageId ) async {
    return await network.getChatMessage(chatRoomId, messageId);
  }

/*
    Callback for branch userChats
    Retrieves active chats which involves the user
    Then, retrieve the information about the chat rooms
   */
  Future<ChatRoomData> getChatRoom(String chatRoomId) async{
    var snapshot = await network.getChatRoomSnapshot(chatRoomId);

    List allMembersPublicId =
    Map<String, bool>.from(snapshot.value['members']).keys.toList();

    ///Note: Might need to add await to getUserDisplayName
    List<String> allMembersDisplayName = [];

    for (String id in allMembersPublicId) {
      allMembersDisplayName.add(await network.getUserDisplayName(id));
    }

    String lastMessageSentID = snapshot.value['lastMessageSent'];
    String lastMessageSent = await network.getChatMessage(
        chatRoomId, lastMessageSentID);
    int lastMessageSentTime = snapshot.value['lastMessageSentTime'];

    return ChatRoomData(
      chatUID: chatRoomId,
      allMembersPublicId: allMembersPublicId,
      allMembers: allMembersDisplayName,
      lastMessageSentUID: lastMessageSentID,
      lastMessageSent: lastMessageSent,
      lastMessageSentTime: lastMessageSentTime,
    );
  }

//  void onNewChat(Event event) async {
//    //Chat Room ID
//    String chatUID = event.snapshot.key;
//
//    var snapshot = await network.getChatRoomSnapshot(chatUID);
//
//    List allMembersPublicId =
//    Map<String, bool>.from(snapshot.value['members']).keys.toList();
//
//    ///Note: Might need to add await to getUserDisplayName
//    List<String> allMembersDisplayName = [];
//
//    for (String id in allMembersPublicId) {
//      allMembersDisplayName.add(await network.getUserDisplayName(id));
//    }
//
//    String lastMessageSentID = snapshot.value['lastMessageSent'];
//    String lastMessageSent = await network.getChatMessage(
//        chatUID, lastMessageSentID);
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
