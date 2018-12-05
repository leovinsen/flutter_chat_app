import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';
import 'package:flutter_chat_app/model/chat_room_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:flutter_chat_app/ui/chat_screen.dart';
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
        : ListView.separated(

        itemCount: chatModels.length,
        separatorBuilder: (_, int index) => Divider(),
        itemBuilder: (_, int index){

          String sentTime = dateFormat.format(DateTime.fromMillisecondsSinceEpoch(
                chatModels[index].lastMessageSentTime));

          return GestureDetector(
            onTap: () => handleClick(context, index),
            child: ListTile(
              dense: false,
              leading: CircleAvatar(
                radius: dimen.listViewCircleAvatarRadius,
                child: Text('C'),
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
    return Text(getContactName(context, index));
  }

  TextStyle dateText(){
    return TextStyle(
      color: Colors.grey
    );
  }

  String getContactName(BuildContext context, int index) {
    AppData appData = AppData.of(context);
    List s = List.from(chatModels[index].allMembers)
      ..remove(appData.userDisplayName);
    return s.first;
  }

  String getContactPublicId(BuildContext context, int index){
    AppData appData = AppData.of(context);
    List s = List.from(chatModels[index].allMembersPublicId)
      ..remove(appData.userPublicId);
    return s.first;
  }

  void handleClick(BuildContext context, int index) {
    AppData appData = AppData.of(context);
    String contactPublicId = getContactPublicId(context, index);
    print(appData.contactsData);
    UserData contactModel = appData.contactsData.singleWhere((contactModel){
      return contactModel.publicId == contactPublicId;
    });

    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ChatScreen(userPublicId: appData.userPublicId, contactModel: contactModel, chatUID: chatModels[index].chatUID, ))
    );

  }
}
