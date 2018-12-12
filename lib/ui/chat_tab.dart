import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';
import 'package:flutter_chat_app/model/chat_room_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:flutter_chat_app/ui/chat_screen.dart';
import 'package:flutter_chat_app/widgets/circular_profile_image.dart';
import 'package:intl/intl.dart';

import '../util/dimensions.dart' as dimen;

class ChatTab extends StatelessWidget {
  final List<ChatRoomData> chatModels;
  final DateFormat dateFormat = new DateFormat('dd/MM/yyyy');

  ChatTab({this.chatModels});

  @override
  Widget build(BuildContext context) {

    chatModels.sort((roomA, roomB){
      return roomA.lastMessageSentTime.compareTo(roomB.lastMessageSentTime);
    });

    return chatModels.isEmpty
        ? Center(child: Text('No chats'))
        : _buildChatRooms(context);
  }

  Widget _buildChatRooms(BuildContext context){
    return ListView.separated(

        itemCount: chatModels.length,
        separatorBuilder: (_, int index) => Divider(),
        itemBuilder: (_, int index){

          String sentTime = dateFormat.format(DateTime.fromMillisecondsSinceEpoch(
              chatModels[index].lastMessageSentTime));

          return GestureDetector(
            onTap: () => handleClick(context, index),
            child: ListTile(
              dense: false,
              leading: FutureBuilder(
                initialData: "",
                future: getContactThumbUrl(context, index),
                builder: (_, snapshot){
                  if(snapshot.hasData){
                    String url = snapshot.data;
                    return CircularNetworkProfileImage(size: dimen.listViewCircleImageSize, url:  url, publicId: getContactPublicId(context,index),);
                  } else {
                    return Container(
                      height: dimen.listViewCircleImageSize,
                      width: dimen.listViewCircleImageSize,
                    );
                  }
                },
              ),


              title: title(context, index),
              subtitle: Text(chatModels[index].lastMessageSent),
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

  Widget title(BuildContext context, int index) {
    return FutureBuilder(
      ///TODO: put cached data into initial dat
      initialData: "",
      future: getContactName(context, index),
      builder: (_, snapshot){
        if(snapshot.hasData){
          return Text(snapshot.data);
        }
      },
    );
  }

  TextStyle dateText(){
    return TextStyle(
      color: Colors.grey
    );
  }

  ////BUG
  ///RETRIEVE DATA FROM FIREBASE!!!
  Future<String> getContactName(BuildContext context, int index) async {
    String publicId = getContactPublicId(context, index);

    DataSnapshot snapshot = await FirebaseDatabase.instance.reference().child('usersInfo/$publicId').once();
    return snapshot.value['displayName'];
//    AppData appData = AppData.of(context);
//    List s = List.from(chatModels[index].allMembers)
//      ..remove(appData.userDisplayName);
  }

  String getContactPublicId(BuildContext context, int index){
    AppData appData = AppData.of(context);
    List s = List.from(chatModels[index].allMembersPublicId)
      ..remove(appData.publicId);
    return s.first;
  }

 Future<String> getContactThumbUrl(BuildContext context, int index) async {
    FirebaseDatabase db = FirebaseDatabase.instance;
    DataSnapshot snapshot = await db.reference().child('usersInfo/${getContactPublicId(context,index)}/thumbUrl').once();
    print(snapshot.value);
    return snapshot.value;
  }

  void handleClick(BuildContext context, int index) {
    AppData appData = AppData.of(context);
    String contactPublicId = getContactPublicId(context, index);
//    var repo = Repository.get();
//    print(appData.contactsData);
    UserData contactModel = appData.contactsData.singleWhere((contactModel){
      return contactModel.publicId == contactPublicId;
    });

    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ChatScreen(userPublicId: appData.publicId, contactModel: contactModel, chatUID: chatModels[index].chatUID, ))
    );

  }


}
