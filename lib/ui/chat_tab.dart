import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';
import 'package:flutter_chat_app/model/chat_room_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:flutter_chat_app/ui/chat_screen.dart';
import 'package:flutter_chat_app/widgets/circular_profile_image.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import '../util/dimensions.dart' as dimen;

class ChatTab extends StatelessWidget {
//  final List<ChatRoomData> chatModels;
  final DateFormat dateFormat = new DateFormat('dd/MM/yyyy');

//  ChatTab({this.chatModels});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppData>(
      builder: (_, child, model){
        List<ChatRoomData> chatRooms =  model.chatRoomData..sort((roomA, roomB){
          return roomA.lastMessageSentTime.compareTo(roomB.lastMessageSentTime);
        });

        return chatRooms.isEmpty
            ? _buildNoChatMessage()
            : _buildChatRooms(context, chatRooms, model);


      },

    );
  }

  Widget _buildNoChatMessage(){
    return Center(child: Text('No chats'));
  }

  Widget _buildChatRooms(BuildContext context, List<ChatRoomData> chatRooms, AppData model) {
    return ListView.separated(

        itemCount: chatRooms.length,
        separatorBuilder: (_, int index) => Divider(),
        itemBuilder: (_, int index) {

          ChatRoomData chatRoom = chatRooms[index];
          String publicId = model.publicId;
          String userDisplayName = model.displayName;
          String contactId = getContactPublicId(chatRoom, publicId);
          String sentTime = dateFormat.format(
              DateTime.fromMillisecondsSinceEpoch(
                  chatRoom.lastMessageSentTime));

          return GestureDetector(
            onTap: () => handleClick(context, contactId, chatRoom.chatUID),
            child: ListTile(
              dense: false,
              leading: FutureBuilder(
                initialData: "",
                future: getContactThumbUrl(contactId),
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    String url = snapshot.data;
                    return CircularNetworkProfileImage(
                      size: dimen.listViewCircleImageSize,
                      url: url,
                      publicId: getContactPublicId(chatRoom, model.publicId),);
                  } else {
                    return Container(
                      height: dimen.listViewCircleImageSize,
                      width: dimen.listViewCircleImageSize,
                    );
                  }
                },
              ),


              title: contactName(userDisplayName, chatRoom),
              subtitle: Text(chatRoom.lastMessageSent),
              trailing: SizedBox(
                height: 40.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(sentTime, style: dateText()),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget contactName(String userDisplayName, ChatRoomData chatRoom) {
    List s = List.from(chatRoom.allMembers)..remove(userDisplayName);
    String contactName = s.first();


    return Text(contactName);
//    return FutureBuilder(
//      ///TODO: put cached data into initial dat
//      initialData: "",
//      future: getContactName(context, index),
//      builder: (_, snapshot){
//        if(snapshot.hasData){
//          return Text(snapshot.data);
//        }
//      },
//    );
  }

  TextStyle dateText(){
    return TextStyle(
      color: Colors.grey
    );
  }

//  ////BUG
//  ///RETRIEVE DATA FROM FIREBASE!!!
//  Future<String> getContactName(BuildContext context, int index) async {
//    String publicId = getContactPublicId(context, index);
//
//    DataSnapshot snapshot = await FirebaseDatabase.instance.reference().child('usersInfo/$publicId').once();
//    return snapshot.value['displayName'];
////    AppData appData = AppData.of(context);
////    List s = List.from(chatModels[index].allMembers)
////      ..remove(appData.userDisplayName);
//  }

  String getContactPublicId(ChatRoomData chatRoom, String userId){
    List s = List.from(chatRoom.allMembersPublicId)..remove(userId);
    return s.first;
  }

  ///TODO: USE FROM CACHE, AND DELEGATE LOADING TO APPDATA
 Future<String> getContactThumbUrl(String publicId) async {
    FirebaseDatabase db = FirebaseDatabase.instance;
    DataSnapshot snapshot = await db.reference().child('usersInfo/$publicId/thumbUrl').once();
    print(snapshot.value);
    return snapshot.value;
  }

  void handleClick(BuildContext context, String contactPublicId, String chatUID) {
    AppData appData = AppData.of(context);
//    var repo = Repository.get();
//    print(appData.contactsData);
    UserData contactModel = appData.contactsData.singleWhere((contactModel){
      return contactModel.publicId == contactPublicId;
    });

    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ChatScreen(userPublicId: appData.publicId, contactModel: contactModel, chatUID: chatUID, ))
    );

  }


}
