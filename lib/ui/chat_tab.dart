import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';
import 'package:flutter_chat_app/model/chat_room_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:flutter_chat_app/ui/chat_screen.dart';
import 'package:intl/intl.dart';

import '../util/dimensions.dart' as dimen;
import '../util/firebase_handler.dart' as firebaseHandler;

class ChatTab extends StatelessWidget {
  final String userPublicId;
  final List<ChatRoomData> chatModels;
  final DateFormat dateFormat = new DateFormat('dd/MM/yyyy');

  ChatTab({this.chatModels, this.userPublicId});

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
              title: title(index),
              subtitle: Text(chatModels[index].lastMessageSent),
              trailing:

              SizedBox(
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

  Widget title(int index) {
    String contactPublicId = getContactPublicId(index);
    return FutureBuilder(
        future: firebaseHandler.getUserModelForPublicId(contactPublicId),
        builder: (_, snapshot){
      if(snapshot.hasData){
        var model = snapshot.data as UserData;
        return Text(model.displayName);
      } else {
        return Text(contactPublicId);
      }
    });
  }

  TextStyle dateText(){
    return TextStyle(
      color: Colors.grey
    );
  }

  String excludeUser(List<String> list){
    if(list.length > 1)list.remove(userPublicId);
    return list.first;
  }

  String getContactPublicId(int index){
    return excludeUser(chatModels[index].members);
  }

  void handleClick(BuildContext context, int index) {
    AppData appData = AppData.of(context);
    String contactPublicId = getContactPublicId(index);
    UserData contactModel = appData.contactsData.singleWhere((contactModel){
      return contactModel.publicId == contactPublicId;
    });

    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ChatScreen(userPublicId: userPublicId, contactModel: contactModel, ))
    );

  }
}
