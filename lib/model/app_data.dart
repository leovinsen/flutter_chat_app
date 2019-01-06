import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/data/repository.dart';
import 'package:flutter_chat_app/model/chat_room_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';

enum AuthStatus {
  notSignedIn,
  incompleteRegistration,
  signedIn,
}

enum AddContact {
  duplicateContact,
  contactDoesNotExist,
  success
}

AuthStatus enumFromString(String str){
  return AuthStatus.values.firstWhere((elem) => elem.toString() == str, orElse: ()=> null);
}

class AppData extends Model {

  static final String tag = "APP_DATA";

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

  Query getChatMessageStream(String chatId) => repo.getChatMessageStream(chatId);

  Future<UserData> getUserDataFor(String publicId) async => await repo.getUserDataFor(publicId, false);

//  Future<UserData> getUserDataFor(String publicId) async {
//    UserData user = await repo.getUserDataFor(publicId, false);
//    return user;
//  }

  Future<void> uploadImage(ImageSource imgSource) async {
    await repo.uploadImage(_publicId, imgSource);
  }

  AppData(){
    initialize();
  }

  Future initialize() async {
    repo = Repository();
    ///Initialize Repository
    await repo.init();
    await _loadSharedPrefs();
    await _loadCache();
    ready = true;
    notifyListeners();
  }

  Future<void> _loadSharedPrefs() async{
    try {
      String token = await repo.loadCacheToken();
      if (token == null) {
        print('$tag: No auth token is found. User is not signed in');
        _status = AuthStatus.notSignedIn;
      } else {
        _token = token;
        String publicId = await repo.loadCachePublicId();
        if (publicId == null) {
          _status = AuthStatus.incompleteRegistration;
        } else {
          _publicId = publicId;
          _displayName = await repo.loadCacheDisplayName();
          _thumbUrl = await repo.loadCacheThumbUrl();
          _refreshUserData();
          _status = AuthStatus.signedIn;
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _loadCache() async {
    try {
      //Load Chat Rooms


      //Load Contacts
      _contactsData = await repo.loadContactsFromCache();
      print('${_contactsData.length} contacts Loaded.');
      for (UserData contact in _contactsData){
        print(contact.toString());
      }
      _chatRoomsData = await repo.loadChatRooms() ?? [];



    } catch (e){
      print('$tag: ' + e.toString());
    }
  }

  void _refreshUserData(){
    repo.getCurrentUserData(_publicId).then((user){
      _displayName = user.displayName;
      _thumbUrl = user.thumbUrl;
      notifyListeners();
    });
  }

  Future<void> refreshContactDataFor(String publicId) async {

    UserData newUser = await repo.getUserDataFor(publicId, true);
    UserData oldUser = singleContact(publicId);

//    UserData oldUser = _contactsData.singleWhere((user){
//      return user.publicId == publicId;
//    });
    _contactsData[_contactsData.indexOf(oldUser)] = newUser;
    print('Successfuly update user $publicId');
    notifyListeners();
  }

  UserData singleContact(String publicId){
    UserData oldUser = _contactsData.singleWhere((user){
      return user.publicId == publicId;
    }, orElse: ()=> null);

    return oldUser;
//    if(oldUser == null) return false;
//
//    _contactsData[_contactsData.indexOf(oldUser)] = newContact;
//    return true;
  }


  Future<void> registerNew(String email, String password) async {
    ///Auth Status etc
    ///Do Error handling, result message etc here
    await repo.registerNewAccount(email, password);
    _status = AuthStatus.incompleteRegistration;
    notifyListeners();
  }

  ///Called when user registers a publicID and Display Name in AdditionalInfoScreen
  Future finishRegistration(String publicId, String displayName) async {
    try {
      await repo.finishRegistration(publicId, displayName);
      _publicId = publicId;
      _displayName = displayName;
      _status = AuthStatus.signedIn;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  ///Called when user signs in through Login Page
  Future signIn(String email, String password) async {
    ///Do Error handling, result message etc here
      ///
      String token = await repo.signIn(email, password);

      String publicId = await repo.getUserPublicId(token);
      if (publicId == null) {
        _status = AuthStatus.incompleteRegistration;
      } else {
        _status = AuthStatus.signedIn;
        _displayName = await repo.getUserDisplayName(publicId);
        _thumbUrl = await repo.getUserThumbUrl(publicId);
        _publicId = publicId;
      }

    notifyListeners();
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



  Future<void> sendMessage(String chatId, String senderId, String receiverId, String message) async {
    await repo.sendMessage(chatId, senderId, receiverId, message);
  }



  ///TODO: Add enum for "ContactAddedAlready" and "ContactExists"
  Future<AddContact> addContact(String contactId) async {
    ///First check if user is already in contact list
    UserData user = _contactsData.singleWhere((user) =>
    user.publicId == contactId, orElse: () => null);

    ///If null, then user has not been added, now check if there exists such user
    if (user == null) {
      print('Adding contact');
      bool b = await repo.addContact(_publicId, contactId);
      return b ? AddContact.success : AddContact.contactDoesNotExist;
    } else {
      return AddContact.duplicateContact;
    }
  }

  ///Function that is called when a new chat room is found in user's chat rooms branch
  void getChatRoomData(Event event) async {
    String chatRoomId = event.snapshot.key;
    print('AppData: chatRoomid is $chatRoomId');
    _chatRoomsData.add(await repo.getChatRoom(chatRoomId));
    _chatRoomSubs.add( repo.newMessagesListener(chatRoomId, updateLastMessageOnChatRoom));
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
      print('Updating chhat');
      String newMessage = await repo.getChatMessage(chatRoom.chatUID, newMessageId);
      chatRoom.lastMessageSent = newMessage;
      notifyListeners();
    } else {
      print('AppData, OnChatNewMessage ERROR: ' +
          event.snapshot.value['lastMessageSent']);
    }
  }

  void updateUserProfile(Event event) async {
    print('updating user profile');
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
    UserData newUser = await repo.getUserDataFor(contactId, true);
    UserData oldUser = singleContact(contactId);
    if(oldUser == null){
      _contactsData.add(newUser);
    } else {
      _contactsData[_contactsData.indexOf(oldUser)] = newUser;
    }
    notifyListeners();
  }

  void initSubscriptions() {
    print("Initiating Subscriptions");
    _onNewContactsSub = repo.newContactListener(publicId, retrieveContactInfo);
    _onNewChatSub = repo.newChatRoomListener(publicId, getChatRoomData);
    _onProfileUpdate = repo.onProfileUpdate(publicId, updateUserProfile);
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
