import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/user_model.dart';
import 'package:flutter_chat_app/ui/chat_screen.dart';
import 'package:flutter_chat_app/util/helper.dart' as helper;
import '../util/dimensions.dart' as dimen;
class ContactsTab extends StatelessWidget {
  final List<UserModel> contacts;
  final UserModel userModel;

  ContactsTab({this.contacts, this.userModel});

  @override
  Widget build(BuildContext context) {
    //print('Rebuilding Contacts SCreen');
    return contacts.isEmpty
        ? Center(child: Text('No contacts'),)
        : Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ListView.separated(
      itemCount: contacts.length,
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => goToChatScreen(context, contacts[index]),
            child: ListTile(
              leading: CircleAvatar(
                radius: dimen.listViewCircleAvatarRadius,
                backgroundColor: Colors.grey,
                  child: Image.asset('assets/profile_default_thumbnail_64px.png'
                  )
              ),
              title: Text(contacts.elementAt(index).displayName),

            ),
          );
      },
    ),
        );
  }

  goToChatScreen(BuildContext context, UserModel contactModel) {
    //helper.createChatRoomIfAbsent(userModel.publicId, contactModel.publicId);
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ChatScreen(userModel: userModel, contactModel: contactModel, ))
    );
  }
}
