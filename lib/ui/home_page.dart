import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/cache_handler.dart';
import 'package:flutter_chat_app/model/chat_room_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:flutter_chat_app/ui/add_contact_screen.dart';
import 'package:flutter_chat_app/ui/chat_tab.dart';
import 'package:flutter_chat_app/ui/contacts_tab.dart';
import 'package:flutter_chat_app/ui/profile_screen.dart';
import 'package:flutter_chat_app/util/firebase_handler.dart' as helper;

class HomePage extends StatefulWidget {
  final VoidCallback onSignOut;
  final String userPublicId;

  HomePage({this.onSignOut, this.userPublicId});
  @override
  _HomePageNewState createState() => _HomePageNewState();
}

class _HomePageNewState extends State<HomePage> {

  UserData userModel;

  List<UserData> contactsModelList = <UserData>[];
  List<ChatRoomData> chatRoomList = <ChatRoomData>[];
  List<StreamSubscription<Event> > chatRoomSubs = [];
  StreamSubscription<Event>  onNewContactsSub;
  StreamSubscription<Event>  onNewChatSub;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    helper.enableCaching();
    //userModel = CacheHandler.getUserModel();
    initUserModel();
    onNewContactsSub = helper.contactsCallback(widget.userPublicId, onNewContact);
    onNewChatSub = helper.chatRoomCallback(widget.userPublicId, onNewChat);
  }

  initUserModel(){
    userModel = UserData(null, null, null);

    //Retrieve user data locally
    //At this point, there is NO publicId is null,
    //However, displayName / thumbUrl can be null
    //For exmaple, logging in from a new device

    String displayName = CacheHandler.getUserDisplayName();
    String thumbUrl = CacheHandler.getUserThumbUrl();

    if(displayName != null && thumbUrl != null){
      UserData model = UserData(widget.userPublicId, displayName, thumbUrl);
      updateUserModel(model);
    }

    helper.getUserModelForPublicId(widget.userPublicId).then((model){
      updateUserModel(model);
    });

  }

  updateUserModel(UserData model){
    setState(() {
      userModel = model;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    onNewContactsSub.cancel();
    onNewChatSub.cancel();
    chatRoomSubs.forEach((sub){
      sub.cancel();
    });
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
              icon: Icon(Icons.exit_to_app),
              onPressed: widget.onSignOut,
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
            //Center(child:Text('A')),Center(child:Text('A')),Center(child:Text('A'))
            ChatTab(chatModels: chatRoomList, userModel: userModel,),
            ContactsTab(contacts: contactsModelList, userModel: userModel,),
            ProfileScreen(user: userModel,)
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

  void onNewChat(Event event){
    String chatUID = event.snapshot.key;
    print('onNewChat: $chatUID');

    helper.getChatRoomModel(chatUID).then((chatRoom){

      setState(() {
        chatRoomList.add(chatRoom);
        chatRoomSubs.add(helper.newMessageCallback(chatUID, onChatNewMessage));
      });
    });


  }

  void onChatNewMessage(Event event) async {
    ChatRoomData chatRoom = chatRoomList.singleWhere((chatRoom){
      return event.snapshot.key == chatRoom.chatUID;
    });
    if(chatRoom.lastMessageSentUID != event.snapshot.value['lastMessageSent']){
      String newMessage = await helper.getChatMessage(chatRoom.chatUID, event.snapshot.value['lastMessageSent']);
      setState(() {
        chatRoom.lastMessageSent = newMessage;
      });
    } else {
      print('HomePage, OnChatNewMessage ' + event.snapshot.value['lastMessageSent']);
    }
  }

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
    return userModel.publicId;
  }

}
