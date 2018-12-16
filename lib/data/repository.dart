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
  static final String tag = "REPO";

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

  Future<Query> getChatMessageStream(String chatId) async {
    return await network.getChatMessagesStream(chatId);
  }

  Future<String> registerNewAccount(String email, String password) async{
    String token = await auth.createUser(email, password);
    sharedPrefs.updateUserAuthToken(token);
    return token;
  }

  Future finishRegistration(String publicId, String displayName) async {
    try {
      //Register on Firebase
      await network.registerPublicId(await getUserAuthToken(), publicId);
      //Update the user's info on firebase
      await network.setUserInfo(
          publicId,
          {UserData.kPublicId: publicId, UserData.kDisplayName: displayName}
          );

      //Update cache
      //await database.insert(UserData(publicId, displayName, null));
      await sharedPrefs.updateUserPublicId(publicId);
      await sharedPrefs.updateUserDisplayName(displayName);
    } catch(e) {
      throw Exception(e.toString());
    }
  }

  Future<String> signIn(String email, String password) async {
    String token = await auth.signIn(email, password);
    await sharedPrefs.updateUserAuthToken(token);
    return token;
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
      //sharedPrefs.updateUserAuthToken(token);
    }
      return token;
    }


  Future<String> getUserPublicId(String token) async {
    String publicId = await sharedPrefs.getUserPublicId();
    print('$tag: Fetching publicID from sharedPrefs $publicId');
    if (publicId == null){
      publicId = await network.getPublicId(token);
      sharedPrefs.updateUserPublicId(publicId);
      print('$tag: Fetching publicId from network: $publicId');
    }
    return publicId;
  }

  Future<String> getUserDisplayName(String publicId) async {
    String name = await sharedPrefs.getUserDisplayName();
    print('$tag: Fetching display name from sharedPrefs: $name');
    if(name == null){
      name = await network.getUserDisplayName(publicId);
      sharedPrefs.updateUserDisplayName(name);
    }
    return name;
  }

  Future<int> addContact(String userId, String contactId) async {
    ///Add to firebase
    await network.addContact(userId, contactId);
    ///Save into database
    return await database.insertContact(contactId);
  }

  Future<List<UserData>> loadContacts() async {
    List list = await database.getAllContactsData();
    List<UserData> users = [];
    list.forEach((map) => users.add(UserData.fromMap(map)));
    return users;
  }

  Future<List<ChatRoomData>> loadChatRooms() async {
    List list = await database.getAllChatRoomsData();
  }


  StreamSubscription<Event> newMessagesListener(String chatRoomId, Function fn)  {
    return network.newMessageCallback(chatRoomId, fn);
  }

  StreamSubscription<Event> newContactListener(String userId, Function fn) {
    return network.newContactCallback(userId, fn);
  }

  StreamSubscription<Event> newChatRoomListener(String userId, Function fn) {
    return network.chatRoomCallback(userId, fn);
  }

  StreamSubscription<Event> onProfileUpdate(String userId,Function fn) {
    return network.profileUpdateListener(userId, fn);
  }

  ///Looks for user's profile by loading from cache or from firebase db
  Future<UserData> getUserDataFor(String publicId) async {
    //Check Cache first
//    UserData user;
//    user = await database.getUserData(publicId);

    //If not found go online

    UserData user;
    user = await database.getUserData(publicId);

    if(user == null) {
      user = await network.getUserData(publicId);
      database.update(user);
    }
    return user;
  }

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


  }
