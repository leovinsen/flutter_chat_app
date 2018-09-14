import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/user_model.dart';
import 'package:flutter_chat_app/ui/add_contact_screen.dart';
import 'package:flutter_chat_app/ui/chat_tab.dart';
import 'package:flutter_chat_app/ui/contacts_tab.dart';
import 'package:flutter_chat_app/ui/profile_screen.dart';
import 'helper.dart' as helper;

class HomePageNew extends StatefulWidget {
  final VoidCallback onSignOut;
  final String userAuthId;
  final UserModel userModel;

  HomePageNew({this.userAuthId, this.onSignOut, this.userModel});
  @override
  _HomePageNewState createState() => _HomePageNewState();
}

class _HomePageNewState extends State<HomePageNew> {
  List<UserModel> contactsModelList = <UserModel>[];
  var onNewContactsSub;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //initializeContactList();
    helper.enableCaching();
    onNewContactsSub = helper.onNewContactsCallback(getPublicId(), onNewContact);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    onNewContactsSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat App'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.person_add),
              onPressed: addContact,
            ),

            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: null,
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
            ChatTab(widget.onSignOut),
            ContactsTab(contacts: contactsModelList,),
            ProfileScreen(user: widget.userModel,)
          ],
        ),
      ),
    );
  }

  void addContact() async {
    final results = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddContactScreen()));
    if(results != null){
      String contactPublicId = results.toString().toLowerCase();

      bool exist = await helper.contactExists(getPublicId(), contactPublicId);

      if (exist){
        //TELL USER THE CONTACT EXISTS ALREADY
        print('Contact Exists alrd');
      } else {


        //Push contact to firebase
        helper.addContact(getPublicId(), contactPublicId);
        //Retrieve user info of the said contact
        //UserModel contactModel = await helper.getUserModelForPublicId(contactPublicId);

      }
    }
  }
//
//  void initializeContactList() async {
//    List<UserModel> list = await helper.retrieveContacts(getPublicId());
//    setState(() {
//      contactsModelList = list;
//    });
//  }

  void onNewContact(Event event){
    Map map = event.snapshot.value;
    String contactId = map.values.first.toString();
    print('OnNewContact: $contactId');
    helper.getUserModelForPublicId(contactId).then((model){
      setState(() {
        contactsModelList.add(model);
      });
    });
    //helper.getUserModelForPublicId(event.)
  }

  String getPublicId(){
    return widget.userModel.publicId;
  }

}
