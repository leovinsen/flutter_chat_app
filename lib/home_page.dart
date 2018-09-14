//import 'dart:async';
//
//import 'package:firebase_database/firebase_database.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter_chat_app/app_model.dart';
//import 'package:firebase_database/ui/firebase_animated_list.dart';
//import 'package:flutter_chat_app/auth.dart';
//import 'package:flutter_chat_app/model/user_model.dart';
//
//class HomePage extends StatefulWidget {
//  final Auth auth;
//  final String uniqueId;
//
//  HomePage(this.auth, this.uniqueId);
//
//  @override
//  HomePageState createState() {
//    return new HomePageState();
//  }
//}
//
//class HomePageState extends State<HomePage> {
//  //final FirebaseDatabase db = FirebaseDatabase.instance;
//  //DatabaseReference usersRef;
//  //DatabaseReference usersInfoRef;
//  //DatabaseReference contactsRef;
//  UserModel user;
//  List<UserModel> contacts;
//
//  AppModel model;
//
//  @override
//  void initState() {
//    // TODO: implement initState
//    super.initState();
//    model = AppModel.of(context);
//    //usersRef = db.reference().child('users');
//    //usersInfoRef = db.reference().child('usersInfo');
//    retrieveUserData();
//
//  }
//
//  void retrieveUserData() async{
//    //Retrieve user's public Id for reference to usersInfo
//    model.usersRef.child(widget.uniqueId).once().then((snapshot) async {
//      if(snapshot == null){
//        print('HOME_PAGE: retrieveUserData() found NULL snapshot');
//      }
//
//      //Retrieve user info
//      await retrieveUserModel(snapshot.value);
//      await retrieveContacts();
//
//    });
//
//  }
//
//  Future<void> retrieveUserModel(String publicId) async {
//    print('retrieving user model');
//    DataSnapshot snapshot = await model.usersInfoRef.child(publicId).once();
//    setState((){
//      user = UserModel.fromSnapshot(snapshot);
//      model.usersInfoRef.child(user.publicId).onChildChanged.listen(_onNewContact);
//      print('finished retrieving user model');
//    });
//  }
//
//  Future<void> retrieveContacts() async {
//
//    print('retrieving contacts for user ${user.publicId}');
//    contacts = <UserModel>[];
//
//    List keys = user.contactsKey;
//    if (keys != null){
//      keys.forEach((contactId){
//
//        model.usersInfoRef.child(contactId).once().then((snapshot){
//          print(snapshot.value);
//          contacts.add(UserModel.fromSnapshot(snapshot));
//          if(contacts.length == user.contactsKey.length){
//            setState(() {
//              print('finished retrieving contacts');
//            });
//          }
//        });
//      });
//    } else {
//      debugPrint('Contacts is null. ERROR');
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    AppModel model = AppModel.of(context);
//
//    return DefaultTabController(
//      length: 3,
//      child: Scaffold(
//        appBar: AppBar(
//          title: Text('Chat App'),actions: <Widget>[
//            IconButton(
//                icon: Icon(Icons.person_add),
//            onPressed: () async{
//                  //final results = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddContactsScreen()));
//                  //if(results != null){
//                  //  _addContact(results);
//                  //}
//            },),
//
//          IconButton(
//            icon: Icon(Icons.refresh),
//            onPressed: (){
//              setState(() {
//
//              });
//            },
//          )
//        ],
//          bottom: TabBar(
//            tabs: <Widget>[
//              Tab(child: Text('CHATS'),),
//              Tab(child: Text('CONTACTS'),),
//              Tab(child: Text('PROFILE'),)
//            ],
//          ),
//        ),
//        body: TabBarView(
//          children: <Widget>[
//            Center(
//              child: Column(
//                children: <Widget>[
//                  SizedBox(height: 50.0,),
//                  user != null
//                      ? Text('Welcome ${user.displayName}, publicId: ${user.publicId}')
//                      : Text('Loading...'),
//
//                  FlatButton(
//                    child: Text('SIGN OUT'),
//                    onPressed: () {
//                      model.signOut();
//                    },
//                  ),
//                ],
//              ),
//            ),
//            createContactsPage(),
//            //contacts == null ? CircularProgressIndicator() : contactsTab ,
//            Text('Profile Tab')
//          ],
//        )
//      ),
//    );
//  }
//
//  void _addContact(String userId) async {
//
//    DataSnapshot snapshot = await model.usersInfoRef.child(userId).once();
//    if(snapshot == null){
//      print('HOME_PAGE | ADDCONTACT: snapshot is null');
//    } else {
//
//      user.addContact(snapshot.value['publicId']);
//
//      model.usersInfoRef.child(user.publicId).set(user.toJson());
//    }
//  }
//
//  Widget createLV(){
//    return ListView.builder(
//      itemCount: contacts.length,
//      itemBuilder: (BuildContext context, int index) {
//        return contacts.isEmpty ? Container(child: Text('No contacts'),):
//        Card(
//          child: ListTile(
//            leading: Image.asset('assets/profile_default_thumbnail_64px'),
//            title: Text(contacts[index].displayName),
//            subtitle: Text('Chat Placeholder'),
//          ),
//        );
//      },
//    );
//  }
//
//
//  Widget createContactsPage(){
//    if(contacts == null){
//      return CircularProgressIndicator();
//    } else {
//      return  ListView.builder(
//        itemCount: contacts.length,
//        itemBuilder: (BuildContext context, int index) {
//          return contacts.isEmpty ? Container(child: Text('No contacts'),):
//           GestureDetector(
//             onTap: () => _removeDialog(context),
//             child: Card(
//               child: ListTile(
//                 contentPadding: const EdgeInsets.all(10.0),
//                 leading: CircleAvatar(
//                   radius: 30.0,
//                   child: Image.asset('assets/profile_default_thumbnail_64px.png'),
//                 ),
//                 title: Text(contacts[index].displayName),
//                 subtitle: Text('Hey, I\'ve just sent you a message! Let\'s talk!'),
//               ),
//          ),
//           );
//        },
//      );
//    }
//  }
//
//  void _onNewContact(Event event) {
//    Map map = event.snapshot.value;
//
//    contacts.add(UserModel.fromSnapshot(event.snapshot));
//    setState(() {
//      print('New contact found');
//    });
//  }
//
//  void _removeContact() async {
//
//
//  }
//
//  void _removeDialog(BuildContext context) async {
//    final results = await showDialog(
//        context: context,
//        builder: (_){
//          return AlertDialog(
//            //title: Text('Remove contact?'),
//            content: Text('Do you want to remove this contact?') ,
//            actions: <Widget>[
//              FlatButton(
//                child: Text("YES"),
//                onPressed: (){
//                  Navigator.pop(context, 'yes');
//                },
//              ),
//              FlatButton(
//                child: Text("NO"),
//                onPressed: (){
//                  Navigator.pop(context, 'no');
//                },
//              )
//            ],
//
//          );
//        }
//    );
//
//    if(results == 'yes') {
//
//    }
//  }
//}
//
