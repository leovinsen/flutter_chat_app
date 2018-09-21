import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/chat_model.dart';
import 'package:flutter_chat_app/model/user_model.dart';
import 'package:flutter_chat_app/ui/chat_screen.dart';
import '../util/helper.dart' as helper;
import '../util/dimensions.dart' as dimen;
import 'package:intl/intl.dart';

class ChatTab extends StatelessWidget {
  //final VoidCallback onSignOut;
  UserModel userModel;
  List<ChatRoomModel> chatModels;

  final DateFormat dateFormat = new DateFormat('dd/MM/yyyy');

  ChatTab({this.chatModels, this.userModel});

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


            onTap: null,
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
    String publicId = excludeUser(chatModels[index].members);
    return FutureBuilder(
        future: helper.getUserModelForPublicId(publicId),
        builder: (_, snapshot){
      if(snapshot.hasData){
        var model = snapshot.data as UserModel;
        return Text(model.displayName);
      } else {
        return Text(publicId);
      }
    });
  }

  TextStyle dateText(){
    return TextStyle(
      color: Colors.grey
    );
  }

  String excludeUser(List<String> list){
    if(list.length > 1)list.remove(userModel.publicId);
    return list.first;
  }
}
