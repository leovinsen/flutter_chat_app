import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/cache_handler.dart';
import 'package:flutter_chat_app/model/chat_room_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:scoped_model/scoped_model.dart';

import '../util/firebase_handler.dart' as firebaseHandler;


class AppData extends Model{

  //FirebaseHandler _firebaseHandler;

  String _firebaseAuthId;
  UserData _userData;
  List<UserData> _contactsData = [];
  List<ChatRoomData> _chatRoomsData = [];

  List<StreamSubscription<Event> > _chatRoomSubs = [];
  StreamSubscription<Event>  _onNewContactsSub;
  StreamSubscription<Event>  _onNewChatSub;

  //FirebaseHandler get firebaseHandler => _firebaseHandler;

  String get firebaseAuthId => _firebaseAuthId;

  String get userPublicId => _userData.publicId;
  String get userDisplayName => _userData.displayName;
  String get userThumbUrl => _userData.displayName;
  UserData get userData => _userData;

  List<UserData> get contactsData => _contactsData;

  List<ChatRoomData> get chatRoomData => _chatRoomsData;

  AppData(String publicId){
    initUserModel(publicId);
    //initSubscriptions();
  }



  initUserModel(String publicId){


    //Retrieve userData from cache
    String displayName = CacheHandler.getUserDisplayName();
    String thumbUrl = CacheHandler.getUserThumbUrl();

    _userData = UserData(publicId, displayName, thumbUrl);
    notifyListeners();

    //Retrieve from firebase
    firebaseHandler.getUserModelForPublicId(publicId).then((data){
      _userData = data;
      notifyListeners();
    });
  }



  void onNewChat(Event event){
    String chatUID = event.snapshot.key;
    print('onNewChat: $chatUID');

    firebaseHandler.getChatRoomModel(chatUID).then((chatRoom){
      _chatRoomsData.add(chatRoom);
      _chatRoomSubs.add(firebaseHandler.newMessageCallback(chatUID, onChatNewMessage));
      notifyListeners();
    });

  }

  void onChatNewMessage(Event event) async {
    ChatRoomData chatRoom =  _chatRoomsData.singleWhere((chatRoom){
      return event.snapshot.key == chatRoom.chatUID;
    });
    if(chatRoom.lastMessageSentUID != event.snapshot.value['lastMessageSent']){
      String newMessage = await firebaseHandler.getChatMessage(chatRoom.chatUID, event.snapshot.value['lastMessageSent']);
      chatRoom.lastMessageSent = newMessage;
      notifyListeners();
    } else {
      print('AppData, OnChatNewMessage ERROR: ' + event.snapshot.value['lastMessageSent'] );
    }
  }

  void onNewContact(Event event){
    Map map = event.snapshot.value;
    String contactId = map.values.first.toString();
    print('OnNewContact: $contactId');
    firebaseHandler.getUserModelForPublicId(contactId).then((model){
      _contactsData.add(model);
      notifyListeners();
    });
  }

  void initSubscriptions(){
    _onNewContactsSub = firebaseHandler.contactsCallback(userPublicId, onNewContact);
    _onNewChatSub = firebaseHandler.chatRoomCallback(userPublicId, onNewChat);
  }

  void cancelSubscriptions(){
    _onNewContactsSub.cancel();
    _onNewChatSub.cancel();
    _chatRoomSubs.forEach((sub){
      sub.cancel();
    });
  }

  static AppData of(BuildContext context) =>
      ScopedModel.of<AppData>(context);

}