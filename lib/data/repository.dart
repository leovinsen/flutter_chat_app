import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chat_app/data/cache_database.dart';
import 'package:flutter_chat_app/data/cache_sharedPrefs.dart';
import 'package:flutter_chat_app/data/network_handler.dart';
import 'package:flutter_chat_app/model/auth.dart';
import 'package:flutter_chat_app/model/chat_room_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';

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

  Query getChatMessageStream(String chatId) {
    return network.getChatMessagesStream(chatId);
  }

  Function get sendMessage => network.insertChatMessage;

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
//    token = await sharedPrefs.getUserAuthToken();
//    if (token == null) {
      print('User auth token not found in SharedPrefs');
      token = await auth.currentUser();
      //sharedPrefs.updateUserAuthToken(token);
//    }
      return token;
    }


  Future<String> getUserPublicId(String token) async {
//    String publicId = await sharedPrefs.getUserPublicId();
//    print('$tag: Fetching publicID from sharedPrefs $publicId');
//    if (publicId == null){
      String publicId = await network.getPublicId(token);
      sharedPrefs.updateUserPublicId(publicId);
//      print('$tag: Fetching publicId from network: $publicId');
//    }
    return publicId;
  }

  Future<String> getUserDisplayName(String publicId) async {
//    String name = await sharedPrefs.getUserDisplayName();
//    print('$tag: Fetching display name from sharedPrefs: $name');
//    if(name == null){
      String name = await network.getUserDisplayName(publicId);
      sharedPrefs.updateUserDisplayName(name);
//    }
    return name;
  }

  Future<String> getUserThumbUrl(String publicId) async {
//    String url = await sharedPrefs.getUserThumbUrl();
//    if(url == null){
      String url = await network.getUserThumbUrl(publicId);
      sharedPrefs.updateUserThumbUrl(url);
//    }
    return url;
  }

  ///Fetches the newest data from network
  ///Then saves it into cache
  Future<UserData> getUserDataFor(String publicId, bool isContact) async {
    //Fetch from network
    UserData user = await network.getUserData(publicId);
    //Save into cache
    int result = await database.update(user, isContact);
    print('DATABASE_UPDATE RESULT: $result');
    if (result == 0) await database.insertUser(user, isContact);

    return user;
  }

  Future<bool> addContact(String userId, String contactId) async {
    ///Add to firebase
    if(await network.usernameExist(contactId)){
      await network.addContact(userId, contactId);
      return true;
    }
    return false;
    ///Save into database
  }

  Future<List<UserData>> loadContacts() async {
    List rawMaps = await database.getAllContactsData();
    List<UserData> users = [];
    rawMaps.forEach((map) => users.add(UserData.fromMap(map)));

//    List<UserData> users = [];
//    for (String id in list){
//      users.add(await database.getUserData(id));
//    }
    return users;
  }



  Future<List> loadSharedPrefs() async {
    var token = await sharedPrefs.getUserAuthToken();


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

    List allMembersPublicId = Map<String, bool>.from(snapshot.value['members']).keys.toList();

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
