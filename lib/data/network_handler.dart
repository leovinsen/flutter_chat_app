import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  Query getChatMessagesStream(String chatId)  {
    print('getchatStream: $chatId');
    return _db.reference().child('$_branchChatMessages/$chatId').orderByChild('messageTime');
  }

  Future<void> insertChatMessage(String chatId, String senderId, String receiverId, String message) async {

    ///insert chat room into both parties' branch at /userChats/
    _db.reference().child('$_branchUserChats/$senderId').update({
      chatId : true
    });
    _db.reference().child('$_branchUserChats/$receiverId').update({
      chatId : true
    });

    ///Create new entry in the /chatMessages/chatUID branch
    DatabaseReference newMessageRef = _db.reference().child('$_branchChatMessages/$chatId').push();
    String newMessageID = newMessageRef.key;
    int timeStamp = DateTime.now().millisecondsSinceEpoch;

    ///Insert chat message
    newMessageRef.update({
      'sentBy' : senderId,
      'messageTime' : timeStamp ,
      'message' : message
    });

    ///Update Chat room's last message sent. Also used to initialize chat room for the first time
    ///branch /chats/
    _db.reference().child('$_branchChats/$chatId').update({
      'members' : {
        senderId : true,
        receiverId : true
      },
      'lastMessageSent' : newMessageID,
      'lastMessageSentTime' : timeStamp,
    });
  }

  Future registerPublicId(String token, String publicId) async {
    return await _db.reference().child('$_branchUsers/$token').set(publicId);
  }

  Future setUserInfo(String publicId, Map<String,String> newData) async {
    return await _db.reference().child('$_branchUsersInfo/$publicId').set(newData);
  }

  Future<void> addContact(String userId, String contactId) async {
    return await _db.reference().child('$_branchUsersContact/$userId/$contactId').set(true);
  }

  Future<bool> usernameExist(String publicId) async {
    print('Checking if $publicId exists');
    var snapshot = await _db.reference().child('$_branchUsersInfo/$publicId').once();
    return snapshot.value != null;
  }

  Future<String> uploadImageTask(String publicId, File imageFile) async {
    StorageReference ref =
    FirebaseStorage.instance.ref().child(publicId).child("profile_picture.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);

    String thumbUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    await _db.reference().child('$_branchUsersInfo/$publicId').update({'thumbUrl' : thumbUrl });
    return thumbUrl;
//    if (mounted) Scaffold.of(context).showSnackBar(SnackBar(content: Text('Upload successful'), duration: Duration(seconds: 2),));
//    debugPrint('Upload successful: $thumbUrl');
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

  Future<String> getUserThumbUrl(String publicId) async {
    DataSnapshot snapshot =
    await _db.reference().child('$_branchUsersInfo/$publicId/${UserData.kThumbUrl}').once();
    return snapshot.value;
  }

  Future<UserData> getUserData(String publicId) async {
    DataSnapshot snapshot =
        await _db.reference().child('$_branchUsersInfo/$publicId').once();

    return snapshot == null ? null : UserData.fromSnapshot(snapshot);
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

  StreamSubscription<Event> newMessageCallback(
      String chatUID, Function(Event) fn) {
    print('$tag: Callback for $_branchChats/$chatUID');
    return _db.reference().child('$_branchChats/$chatUID').onValue.listen(fn);
  }

  StreamSubscription<Event> profileUpdateListener(String publicId, Function(Event) fn){
    return _db.reference().child('$_branchUsersInfo/$publicId').onChildChanged.listen(fn);
  }



}