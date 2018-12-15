import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chat_app/model/user_data.dart';

class NetworkHandler {

  static final tag = 'NETWORK_HANDLER';
  static final NetworkHandler instance = NetworkHandler._internal();
  static final FirebaseDatabase _db = FirebaseDatabase.instance;

  final String _branchUsersContact = 'usersContacts';
  final String _branchUserChats = 'usersChats';
  final String _branchChats ='chats';
  final String _branchUsersInfo ='usersInfo';
  final String _branchUsers ='users';
  final String _branchChatMessages = 'chatsMessages';


  NetworkHandler._internal();

  Future<String> getPublicId(String token) async {
    var snapshot = await _db.reference().child('$_branchUsers/$token').once();
    return snapshot.value;
  }

  Future registerPublicId(String token, String publicId) async {
    return await _db.reference().child('$_branchUsers/$token').set(publicId);
  }

  Future setUserInfo(String publicId, Map<String,String> newData) async {
    return await _db.reference().child('$_branchUsersInfo/$publicId').set(newData);
  }

  Future<void> addContact(String userId, String contactId) async {
    return await _db.reference().child('$_branchUsersInfo/$userId/$contactId').set(true);
  }


  Future<String> getChatMessage(String chatUID, String messageUID) async {
    DataSnapshot snapshot =
        await _db.reference().child('$_branchChatMessages/$chatUID/$messageUID').once();
    return snapshot.value['message'];
  }

  Future<String> getUserDisplayName(String publicId) async {
    DataSnapshot snapshot =
        await _db.reference().child('$_branchUsersInfo/$publicId/${UserData.kDisplayName}').once();
    return snapshot.value;
  }

  Future<UserData> getUserData(String publicId) async {
    DataSnapshot snapshot =
        await _db.reference().child('$_branchUsersInfo/$publicId').once();
    return UserData.fromSnapshot(snapshot);
  }

  Future<DataSnapshot> getChatRoomSnapshot(String chatId) async{
    return await _db.reference().child('$_branchChats/$chatId').once();
  }

  StreamSubscription<Event> newContactCallback(
      String publicId, Function(Event) fn) {
    return _db
        .reference()
        .child('$_branchUsersContact/$publicId')
        .onChildAdded
        .listen(fn);
  }

  StreamSubscription<Event> chatRoomCallback(
      String publicId, Function(Event) fn) {
    return _db
        .reference()
        .child('$_branchUserChats/$publicId')
        .orderByChild('lastMessageSentTime')
        .onChildAdded
        .listen(fn);
  }

//  StreamSubscription<Event> newMessageCallback(
//      String chatUID, Function(Event) fn) {
//    return _db.reference().child('chats/$chatUID').onValue.listen(fn);
//  }
//
  StreamSubscription<Event> newMessageCallback(
      String chatUID, Function(Event) fn) {
    print('$tag: Callback for $_branchChats/$chatUID');
    return _db.reference().child('$_branchChats/$chatUID').onValue.listen(fn);
  }

  StreamSubscription<Event> profileUpdateListener(String publicId, Function(Event) fn){
    return _db.reference().child('$_branchUsersInfo/$publicId').onChildChanged.listen(fn);
  }



}