import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';
import 'package:flutter_chat_app/ui/add_contact_screen.dart';
import 'package:flutter_chat_app/ui/chat_tab.dart';
import 'package:flutter_chat_app/ui/contacts_tab.dart';
import 'package:flutter_chat_app/ui/profile_screen.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onSignOut;

  HomePage({this.onSignOut});
  @override
  _HomePageNewState createState() => _HomePageNewState();
}

class _HomePageNewState extends State<HomePage> {

  AppData appData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    appData = AppData.of(context);
    appData.initSubscriptions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //appData.initSubscriptions();
    return ScopedModelDescendant<AppData>(
      builder: (context, child, model) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Chat App'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      model.contactsData.forEach((user) {
                        print(user.toString());
                      });
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.person_add),
                  onPressed: addContact,
                ),

                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    appData.cancelSubscriptions();
                    widget.onSignOut();
                  },
                )
              ],

              bottom: TabBar(
                tabs: <Widget>[
                  Tab(child: Text('CHATS'),),
                  Tab(child: Text('CONTACTS'),),
                  Tab(child: Text('PROFILE'),)
                ],
              ),
            ),

            body: TabBarView(
              children: <Widget>[
                ChatTab(chatModels: model.chatRoomData,
//                    userPublicId: model.userPublicId
                ),
                ContactsTab(contacts: model.contactsData,
                    userPublicId: model.userPublicId),
                ProfileScreen(appData: model)
              ],
            ),
          ),
        );
      },
    );
  }

  void addContact() async {
    final results = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => AddContactScreen()));
    if (results != null) {
      var model = AppData.of(context);
      FirebaseDatabase db = FirebaseDatabase.instance;

      String contactPublicId = results.toString().toLowerCase();

      bool exist = await db.reference().child(
          'userContacts/${model.userPublicId}/$contactPublicId').once().then((
          snapshot) {
        return snapshot.value != null;
      });

//      bool exist = await firebaseHandler.contactExists(
//          model.userPublicId, contactPublicId);

      if (exist) {
        //TELL USER THE CONTACT EXISTS ALREADY
        print('Contact Exists alrd');
      } else {
        //Push contact to firebase
        db.reference().child('usersContact/${model.userPublicId}/$contactPublicId}')
            .push()
            .set(contactPublicId);


//        firebaseHandler.addContact(model.userPublicId, contactPublicId);
        //Retrieve user info of the said contact
        //UserModel contactModel = await helper.getUserModelForPublicId(contactPublicId);

      }
    }
  }

}
