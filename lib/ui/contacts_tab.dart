import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/user_model.dart';
import 'package:flutter_chat_app/ui/chat_screen.dart';
class ContactsTab extends StatelessWidget {
  final List<UserModel> contacts;

  ContactsTab({this.contacts});

  @override
  Widget build(BuildContext context) {
    //print('Rebuilding Contacts SCreen');
    return contacts.isEmpty
        ? Center(child: Text('No contacts'),)
        : ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () => goToChatScreen(context, contacts[index]),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 30.0,
                backgroundColor: Colors.grey,
                  child: Image.asset('assets/profile_default_thumbnail_64px.png'
                  )
              ),
              title: Text(contacts.elementAt(index).displayName),
              subtitle: Text('Chat Placeholder'),
            ),
          ),
        );
      },
    );
  }

  goToChatScreen(BuildContext context, UserModel model) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ChatScreen(userModel: model,))
    );
  }
}
