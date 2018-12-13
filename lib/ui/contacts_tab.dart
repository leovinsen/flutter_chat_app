import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:flutter_chat_app/ui/chat_screen.dart';
import 'package:flutter_chat_app/widgets/circular_profile_image.dart';
import 'package:scoped_model/scoped_model.dart';

import '../util/dimensions.dart' as dimen;
class ContactsTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<AppData>(
      builder: (_, child, model){
        List<UserData> contacts = model.contactsData;
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
                onTap: () => goToChatScreen(context, model.publicId, contact),
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
      },
    );



  }

  goToChatScreen(BuildContext context, String userPublicId, UserData contactModel) {
    //helper.createChatRoomIfAbsent(userModel.publicId, contactModel.publicId);
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ChatScreen(userPublicId: userPublicId, contactModel: contactModel, ))
    );
  }
}
