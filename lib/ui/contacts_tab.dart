import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:flutter_chat_app/ui/chat_screen.dart';
import 'package:flutter_chat_app/widgets/circular_profile_image.dart';

import '../util/dimensions.dart' as dimen;
class ContactsTab extends StatelessWidget {
  final List<UserData> contacts;
  //final UserData userModel;
  final String userPublicId;

  ContactsTab({this.contacts, this.userPublicId});

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

        UserData contact = contacts[index];
          return GestureDetector(
            onTap: () => goToChatScreen(context, contact),
            child: ListTile(
              leading: CircularNetworkProfileImage(
                size: dimen.listViewCircleImageSize,
                url: contact.thumbUrl,
                publicId: contact.publicId,
              ),
              title: Text(contacts.elementAt(index).displayName),

            ),
          );
      },
    ),
        );
  }

  goToChatScreen(BuildContext context, UserData contactModel) {
    //helper.createChatRoomIfAbsent(userModel.publicId, contactModel.publicId);
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ChatScreen(userPublicId: userPublicId, contactModel: contactModel, ))
    );
  }
}
