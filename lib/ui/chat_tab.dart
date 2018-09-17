import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/chat_model.dart';

class ChatTab extends StatelessWidget {
  //final VoidCallback onSignOut;

  List<ChatRoomModel> chatModels;

  ChatTab(this.chatModels);

  @override
  Widget build(BuildContext context) {
    return chatModels.isEmpty
        ? Center(child: Text('No chats'))
        : ListView.builder(
        itemCount: chatModels.length,
        itemBuilder: (_, int index){
          return GestureDetector(
            onTap: null,
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('C'),
                ),
                title: Text(chatModels[index].members.toString()),
                subtitle: Text(chatModels[index].lastMessageSent),
              ),
            ),
          );
        });
  }
}
