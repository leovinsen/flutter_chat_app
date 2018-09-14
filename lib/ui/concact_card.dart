import 'package:flutter/material.dart';

class ContactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

//  Widget createContactsPage(){
//    if(contacts == null){
//      return CircularProgressIndicator();
//    } else {
//      return  ListView.builder(
//        itemCount: contacts.length,
//        itemBuilder: (BuildContext context, int index) {
//          return contacts.isEmpty ? Container(child: Text('No contacts'),):
//          GestureDetector(
//            onTap: () => _removeDialog(context),
//            child: Card(
//              child: ListTile(
//                contentPadding: const EdgeInsets.all(10.0),
//                leading: CircleAvatar(
//                  radius: 30.0,
//                  child: Image.asset('assets/profile_default_thumbnail_64px.png'),
//                ),
//                title: Text(contacts[index].displayName),
//                subtitle: Text('Hey, I\'ve just sent you a message! Let\'s talk!'),
//              ),
//            ),
//          );
//        },
//      );
//    }
//  }


}
