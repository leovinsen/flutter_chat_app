import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chat_app/model/user_model.dart';

FirebaseDatabase db = FirebaseDatabase.instance;
DatabaseReference usersRef = db.reference().child('users');
DatabaseReference usersInfoRef = db.reference().child('usersInfo');
DatabaseReference usersContactRef = db.reference().child('usersContact');
DatabaseReference chatRef = db.reference().child('chats');
DatabaseReference chatMessagesRef = db.reference().child('chatMessages');
DatabaseReference userChatsRef = db.reference().child('userChats');

void enableCaching(){
  db.setPersistenceEnabled(true);
}

Future<void> createUserAssociation(String uniqueAuthId, String publicId){
  return usersRef.child(uniqueAuthId).set(publicId);
}

Future<bool> contactExists(String publicId, String contactId) async{
  DataSnapshot snapshot = await usersContactRef.child(publicId).child(contactId).once();
  return snapshot.value != null;
}

Future<void> addContact(String userPublicId, String contactPublicId){
  return usersContactRef.child(userPublicId).child(contactPublicId).push().set(contactPublicId);
}

Future<void> updateUsersInfo(UserModel model){
  return usersInfoRef.child(model.publicId).set(model.toJson());
}

Future<String> getUserPublicId(String uniqueAuthId)async {
  DataSnapshot snapshot = await usersRef.child(uniqueAuthId).once();
  return snapshot.value;
}

//Future<bool> isUserFullyRegistered(String uniqueAuthId) async {
//  DataSnapshot snapshot = await getUserPublicId(uniqueAuthId);
//  return snapshot.value != null;
//}

Future<UserModel> getUserModelForPublicId(String publicId) async{
  UserModel model;
  DataSnapshot snapshot = await usersInfoRef.child(publicId).once();
  model = UserModel.fromSnapshot(snapshot);
  return model;

}

dynamic onNewContactsCallback(String publicId, Function(Event) fn) {
  return usersContactRef
      .child(publicId)
      .onChildAdded
      .listen(fn);
}

//Future<List<UserModel>> retrieveContacts(String publicId) async {
//  List<UserModel> list = <UserModel>[];
//  DataSnapshot contactList = await retrieveContactsList(publicId);
//  print(contactList.value);
//  if(contactList.value == null) return list;
//  Map map = contactList.value;
//  map.keys.forEach((publicId) async {
//    list.add(await getUserModelForPublicId(publicId));
//
//  });
//  print('list right before return: ${list.toString()}');
//  return list;
//}
//
//Future<DataSnapshot> retrieveContactsList(String publicId){
//  return usersContactRef.child(publicId).once();
//}
//
